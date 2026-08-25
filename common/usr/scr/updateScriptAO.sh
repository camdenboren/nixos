#!/usr/bin/env nix
#!nix shell nixpkgs#curl nixpkgs#jq nixpkgs#perl nixpkgs#gitMinimal --command bash

set -Eeuo pipefail

post_id="${1:?missing Patreon post ID}"
archive_stem="${2:?missing archive stem}"
relative_package_file="hosts/main/usr/drv/${3:?missing package filename}"

die() {
  echo "analog-obsession updater: $*" >&2
  exit 1
}

repo_root="$(git rev-parse --show-toplevel)"
package_file="$repo_root/$relative_package_file"
[[ -f "$package_file" ]] || die "package file not found: $package_file"

download_url="$(
  curl -LfsS \
    -A 'nix-analog-obsession-updater/1' \
    "https://www.patreon.com/api/posts/$post_id" |
    jq -er '
      first(
        .data.attributes.content_json_string
        | fromjson
        | ..
        | objects
        | select(.text? == "Windows Zip")
        | .marks[]?
        | select(.type == "link")
        | .attrs.href
      )
    '
)"

case "$download_url" in
  https://analogobsession.com/*|https://www.analogobsession.com/*) ;;
  *) die "unexpected download URL: $download_url" ;;
esac

archive="${download_url%%\?*}"
archive="${archive##*/}"

prefix="${archive_stem}_"
[[ "$archive" == "$prefix"*.zip ]] ||
  die "unexpected archive name: $archive"

new_version="${archive#"$prefix"}"
new_version="${new_version%.zip}"

[[ "$new_version" =~ ^[0-9]+([.][0-9]+)*$ ]] ||
  die "could not derive version from $archive"

new_hash="$(
  nix --extra-experimental-features nix-command \
    store prefetch-file --json --unpack "$download_url" |
    jq -er .hash
)"

old_version="$(perl -ne 'print "$1\n" if /^\s*version = "([^"]+)";/' "$package_file")"
old_url="$(perl -ne 'print "$1\n" if /^\s*url = "([^"]+)";/' "$package_file")"
old_hash="$(perl -ne 'print "$1\n" if /^\s*hash = "([^"]+)";/' "$package_file")"

[[ -n "$old_version" && -n "$old_url" && -n "$old_hash" ]] ||
  die "could not read existing version, URL, or hash"

if [[
  "$old_version" == "$new_version" &&
  "$old_url" == "$download_url" &&
  "$old_hash" == "$new_hash"
]]; then
  echo "${archive_stem}: already up to date at ${new_version}"
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

AO_OLD_VERSION="$old_version" \
AO_NEW_VERSION="$new_version" \
AO_OLD_URL="$old_url" \
AO_NEW_URL="$download_url" \
AO_OLD_HASH="$old_hash" \
AO_NEW_HASH="$new_hash" \
perl -0pi -e '
  my $versions =
    s{\Qversion = "$ENV{AO_OLD_VERSION}";\E}
     {version = "$ENV{AO_NEW_VERSION}";}g;
  my $urls =
    s{\Qurl = "$ENV{AO_OLD_URL}";\E}
     {url = "$ENV{AO_NEW_URL}";}g;
  my $hashes =
    s{\Qhash = "$ENV{AO_OLD_HASH}";\E}
     {hash = "$ENV{AO_NEW_HASH}";}g;

  die "expected exactly one version, URL, and hash\n"
    unless $versions == 1 && $urls == 1 && $hashes == 1;
' "$package_file"

echo "${archive_stem}: ${old_version} -> ${new_version}"
