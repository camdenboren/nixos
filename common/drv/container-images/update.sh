#!/usr/bin/env nix
#!nix shell nixpkgs#curl nixpkgs#jq nixpkgs#nix-prefetch-docker --command bash

# Re-pins images in sources.json to the digest of their tag, and the hash of
# the resulting archive. Entries with "track": "semver" first move to the
# highest x.y.z tag in their registry, so pins follow upstream releases instead
# of floating tags like :latest. "trackPrefix" (for example "v") and
# "trackSuffix" (for example "-cuda") match tags with that decoration around
# the version, and limit it to one variant of a multi-variant image. Other
# entries keep their tag.
#
# Usage: update.sh [key]. nix-update sets UPDATE_NIX_ATTR_PATH (for example
# container-images.invokeai); that key is used when no argument is given.
#
# A tracked image that fails to resolve or prefetch aborts the run without
# writing, so related images (penpot backend/frontend/exporter) can't end up
# on different versions. Untracked images keep their current pin on failure.

set -Eeuo pipefail

die() {
  echo "container-images updater: $*" >&2
  exit 1
}

repo_root="$(git rev-parse --show-toplevel)"
dir="$repo_root/common/drv/container-images"
sources="$dir/sources.json"
[[ -f "$sources" ]] || die "sources file not found: $sources"

work_dir="$(mktemp -d)"
trap 'rm -rf "$work_dir"' EXIT

# Lists every tag in a repository, following registry pagination.
# Explicitly propagate failures: the caller's `|| die` disables errexit here.
list_tags() {
  local registry=$1 repo=$2 host auth token next link page headers
  case "$registry" in
    ghcr.io)
      host=ghcr.io
      auth="https://ghcr.io/token?scope=repository:${repo}:pull"
      ;;
    docker.io)
      host=registry-1.docker.io
      auth="https://auth.docker.io/token?service=registry.docker.io&scope=repository:${repo}:pull"
      ;;
    *) die "unsupported registry: $registry" ;;
  esac

  token="$(
    curl --fail --silent --show-error --location --retry 3 \
      --user-agent 'nix-container-images-updater/1' "$auth" \
      | jq -er .token
  )" || return 1

  headers="$work_dir/headers"
  next="https://${host}/v2/${repo}/tags/list?n=1000"
  while [[ -n "$next" ]]; do
    : >"$headers" || return 1
    page="$(
      curl --fail --silent --show-error --location --retry 3 \
        --user-agent 'nix-container-images-updater/1' \
        -D "$headers" -H "Authorization: Bearer ${token}" "$next"
    )" || return 1
    jq -er '.tags[]' <<<"$page" || return 1

    link="$(
      tr -d '\r' <"$headers" \
        | sed -n 's/^[Ll]ink: <\(.*\)>; *rel="next".*/\1/p' \
        | tail -1
    )" || return 1
    case "$link" in
      "") next="" ;;
      /*) next="https://${host}${link}" ;;
      *) next="$link" ;;
    esac
  done
}

# Prints the version part of a tag (without prefix or suffix).
tag_version() {
  local t=$1 prefix=$2 suffix=$3
  t=${t#"$prefix"}
  printf '%s\n' "${t%"$suffix"}"
}

# Prints the highest x.y.z tag with the given prefix and suffix (empty if none),
# as the registry spells it. Registry errors exit the script.
latest_semver_tag() {
  local registry=$1 repo=$2 prefix=$3 suffix=$4 tags matches version
  tags="$(list_tags "$registry" "$repo")" \
    || die "could not list tags for $registry/$repo"
  matches="$(grep -E "^${prefix}[0-9]+\.[0-9]+\.[0-9]+${suffix}\$" <<<"$tags" || true)"
  echo "$registry/$repo: $(wc -l <<<"$tags") tags, $(grep -c . <<<"$matches" || true) matching '${prefix}x.y.z${suffix}'" >&2
  [[ -n "$matches" ]] || return 0
  version="$(
    while IFS= read -r t; do tag_version "$t" "$prefix" "$suffix"; done <<<"$matches" \
      | sort -V | tail -1
  )"
  printf '%s%s%s\n' "$prefix" "$version" "$suffix"
}

# Prints "registry repo" for an image name such as ghcr.io/owner/name or
# owner/name (Docker Hub).
split_image() {
  local name=$1 first=${1%%/*}
  if [[ "$name" == */* && ( "$first" == *.* || "$first" == localhost ) ]]; then
    printf '%s %s\n' "$first" "${name#*/}"
  elif [[ "$name" == */* ]]; then
    printf 'docker.io %s\n' "$name"
  else
    printf 'docker.io library/%s\n' "$name"
  fi
}

scope="${1:-${UPDATE_NIX_ATTR_PATH:-}}"
scope="${scope##*.}"
if [[ -n "$scope" ]]; then
  jq -e --arg k "$scope" 'has($k)' "$sources" >/dev/null \
    || die "no such entry in sources.json: $scope"
fi

updated="$(cat "$sources")"
changed=false
for key in $(jq -r 'keys[]' "$sources"); do
  if [[ -n "$scope" && "$key" != "$scope" ]]; then
    continue
  fi

  entry="$(jq -c --arg k "$key" '.[$k]' "$sources")"
  name="$(jq -r .imageName <<<"$entry")"
  tag="$(jq -r .tag <<<"$entry")"
  track="$(jq -r '.track // ""' <<<"$entry")"
  prefix="$(jq -r '.trackPrefix // ""' <<<"$entry")"
  suffix="$(jq -r '.trackSuffix // ""' <<<"$entry")"
  new_tag="$tag"

  if [[ "$track" == semver ]]; then
    read -r registry repo < <(split_image "$name")
    candidate="$(latest_semver_tag "$registry" "$repo" "$prefix" "$suffix")"
    [[ -n "$candidate" ]] || die "$name: no ${prefix}x.y.z${suffix} tags found in $registry"

    # Only move forward. A tag that isn't a version (such as "latest") always
    # takes the candidate, since it doesn't sort against version numbers.
    new_tag="$candidate"
    if [[ "$tag" =~ ^${prefix}[0-9]+\.[0-9]+\.[0-9]+${suffix}$ ]]; then
      newest="$(printf '%s\n%s\n' "$(tag_version "$tag" "$prefix" "$suffix")" \
        "$(tag_version "$candidate" "$prefix" "$suffix")" | sort -V | tail -1)"
      [[ "$newest" == "$(tag_version "$candidate" "$prefix" "$suffix")" ]] || new_tag="$tag"
    fi

    # a version already at the newest release has nothing to re-pin, so skip
    # the (large) prefetch
    if [[ "$new_tag" == "$tag" ]]; then
      echo "$name:$tag is already the newest release, skipping"
      continue
    fi
  fi

  echo "prefetching $name:$new_tag"
  if entry_json="$(
    nix-prefetch-docker --quiet --json --os linux --arch amd64 \
      --image-name "$name" --image-tag "$new_tag" \
      --final-image-name "$name" --final-image-tag "$new_tag"
  )"; then
    updated="$(
      jq --arg k "$key" --argjson e "$entry_json" '.[$k] = {
        imageName: $e.imageName,
        tag: $e.finalImageTag,
        imageDigest: $e.imageDigest,
        hash: $e.hash
      } + (if .[$k].track then {track: .[$k].track} else {} end)
        + (if .[$k].trackPrefix then {trackPrefix: .[$k].trackPrefix} else {} end)
        + (if .[$k].trackSuffix then {trackSuffix: .[$k].trackSuffix} else {} end)' <<<"$updated"
    )"
  elif [[ -n "$track" ]]; then
    die "could not prefetch $name:$new_tag"
  else
    echo "::warning::could not prefetch $name:$new_tag, keeping its current pin" >&2
  fi
done

jq -S . <<<"$updated" >"$work_dir/sources.json"
if ! cmp -s "$work_dir/sources.json" "$sources"; then
  changed=true
fi
if [[ "$changed" == true ]]; then
  cp "$work_dir/sources.json" "$sources"
  echo "updated sources.json"
else
  echo "container images are already up to date"
fi
