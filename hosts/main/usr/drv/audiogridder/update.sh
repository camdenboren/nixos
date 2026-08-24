#!/usr/bin/env nix-shell
#!nix-shell -i bash -p coreutils curl htmlq jq nix perl gitMinimal

set -Eeuo pipefail

die() {
  echo "AudioGridder updater: $*" >&2
  exit 1
}

repo_root="$(git rev-parse --show-toplevel)"
package_file="$repo_root/hosts/main/usr/drv/audiogridder/default.nix"

[[ -f "$package_file" ]] || die "package file not found: $package_file"

mapfile -t download_links < <(
  curl \
    --fail \
    --silent \
    --show-error \
    --location \
    --retry 3 \
    --user-agent 'nix-audiogridder-updater/1' \
    'https://audiogridder.com/download/' \
    | htmlq --attribute href 'a[href*="AudioGridder_"][href$="-Linux.zip"]'
)

(( ${#download_links[@]} > 0 )) \
  || die "no Linux binary download links found"

versions=()
paths=()

for download_link in "${download_links[@]}"; do
  case "$download_link" in
    https://audiogridder.com/*)
      download_path="${download_link#https://audiogridder.com}"
      ;;
    /*)
      download_path="$download_link"
      ;;
    *)
      continue
      ;;
  esac

  if [[ "$download_path" =~ ^/github/releases/download/release_([0-9]+(_[0-9]+)+)/AudioGridder_([0-9]+([.][0-9]+)+)-Linux[.]zip$ ]]; then
    release_code="${BASH_REMATCH[1]}"
    candidate_version="${BASH_REMATCH[3]}"

    [[ "${candidate_version//./_}" == "$release_code" ]] \
      || die "release path and filename disagree: $download_path"

    versions+=("$candidate_version")
    paths+=("$download_path")
  fi
done

(( ${#versions[@]} > 0 )) \
  || die "no recognized Linux binary download links found"

new_version="$(printf '%s\n' "${versions[@]}" | sort --version-sort --unique | tail -n 1)"
expected_path="/github/releases/download/release_${new_version//./_}/AudioGridder_${new_version}-Linux.zip"
found_expected_path=false

for download_path in "${paths[@]}"; do
  if [[ "$download_path" == "$expected_path" ]]; then
    found_expected_path=true
    break
  fi
done

[[ "$found_expected_path" == true ]] \
  || die "latest version has an unexpected download path"

download_url="https://audiogridder.com$expected_path"
new_hash="$(
  nix --extra-experimental-features nix-command \
    store prefetch-file \
    --json \
    --unpack \
    --name source \
    "$download_url" \
    | jq -er .hash
)"

old_version="$(
  perl -ne 'print "$1\n" if /^\s*version = "([^"]+)";/' "$package_file"
)"
old_url="$(
  perl -ne 'print "$1\n" if /^\s*url = "([^"]+)";/' "$package_file"
)"
old_hash="$(
  perl -ne 'print "$1\n" if /^\s*hash = "([^"]+)";/' "$package_file"
)"

[[ "$old_version" =~ ^[0-9]+([.][0-9]+)+$ ]] \
  || die "could not read the existing version"
[[ "$old_url" == https://audiogridder.com/* ]] \
  || die "could not read the existing source URL"
[[ "$old_hash" == sha256-* ]] \
  || die "could not read the existing source hash"

if [[ "$old_version" == "$new_version" && "$old_url" == "$download_url" && "$old_hash" == "$new_hash" ]]; then
  echo "AudioGridder is already up to date at $new_version"
  exit 0
fi

backup="$(mktemp)"
cp -p "$package_file" "$backup"

cleanup() {
  local status=$?
  trap - EXIT

  if (( status != 0 )); then
    cp -p "$backup" "$package_file"
  fi

  rm -f "$backup"
  exit "$status"
}
trap cleanup EXIT

AUDIOGRIDDER_OLD_VERSION="$old_version" \
AUDIOGRIDDER_NEW_VERSION="$new_version" \
AUDIOGRIDDER_OLD_URL="$old_url" \
AUDIOGRIDDER_NEW_URL="$download_url" \
AUDIOGRIDDER_OLD_HASH="$old_hash" \
AUDIOGRIDDER_NEW_HASH="$new_hash" \
perl -0pi -e '
  my $versions =
    s{\Qversion = "$ENV{AUDIOGRIDDER_OLD_VERSION}";\E}
     {version = "$ENV{AUDIOGRIDDER_NEW_VERSION}";}g;
  my $urls =
    s{\Qurl = "$ENV{AUDIOGRIDDER_OLD_URL}";\E}
     {url = "$ENV{AUDIOGRIDDER_NEW_URL}";}g;
  my $hashes =
    s{\Qhash = "$ENV{AUDIOGRIDDER_OLD_HASH}";\E}
     {hash = "$ENV{AUDIOGRIDDER_NEW_HASH}";}g;

  die "expected exactly one version, source URL, and source hash\n"
    unless $versions == 1 && $urls == 1 && $hashes == 1;
' "$package_file"

echo "AudioGridder: $old_version -> $new_version"
