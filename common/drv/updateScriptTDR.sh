#!/usr/bin/env nix
#!nix shell nixpkgs#curl nixpkgs#htmlq nixpkgs#jq nixpkgs#perl nixpkgs#gitMinimal --command bash

set -Eeuo pipefail

page_slug="${1:?missing Tokyo Dawn page slug}"
lab_name="${2:?missing Tokyo Dawn lab name}"
relative_package_file="common/drv/${3:?missing package filename}"

die() {
  echo "Tokyo Dawn updater: $*" >&2
  exit 1
}

repo_root="$(git rev-parse --show-toplevel)"
package_file="$repo_root/$relative_package_file"

[[ -f "$package_file" ]] || die "package file not found: $package_file"

download_url="$(
  curl \
    --fail \
    --silent \
    --show-error \
    --location \
    --retry 3 \
    --user-agent 'nix-tokyo-dawn-updater/1' \
    "https://www.tokyodawn.net/$page_slug/" \
    | htmlq --attribute href 'a[title*="Windows (No Installer)"]'
)"

[[ -n "$download_url" && "$download_url" != *$'\n'* ]] \
  || die "expected exactly one Windows no-installer link"

# htmlq decodes spaces in attribute values, while the derivations use encoded URLs.
download_url="${download_url// /%20}"

url_prefix="https://www.tokyodawn.net/labs/$lab_name/"
[[ "$download_url" == "$url_prefix"* ]] \
  || die "unexpected download URL: $download_url"

version_and_archive="${download_url#"$url_prefix"}"
new_version="${version_and_archive%%/*}"

[[ "$new_version" =~ ^[0-9]+([.][0-9]+)*$ ]] \
  || die "could not derive a version from $download_url"

escaped_lab_name="${lab_name// /%20}"
expected_url="${url_prefix}${new_version}/TDR%20${escaped_lab_name}%20(no%20installer).zip"

[[ "$download_url" == "$expected_url" ]] \
  || die "download filename changed: $download_url"

# --name avoids illegal store names after Nix decodes the spaces in the URL.
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
old_hash="$(
  perl -ne 'print "$1\n" if /^\s*hash = "([^"]+)";/' "$package_file"
)"

[[ "$old_version" =~ ^[0-9]+([.][0-9]+)*$ ]] \
  || die "could not read the existing version"
[[ "$old_hash" == sha256-* ]] \
  || die "could not read the existing source hash"

if [[ "$old_version" == "$new_version" && "$old_hash" == "$new_hash" ]]; then
  echo "$lab_name is already up to date at $new_version"
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

TDR_OLD_VERSION="$old_version" \
TDR_NEW_VERSION="$new_version" \
TDR_OLD_HASH="$old_hash" \
TDR_NEW_HASH="$new_hash" \
perl -0pi -e '
  my $versions =
    s{\Qversion = "$ENV{TDR_OLD_VERSION}";\E}
     {version = "$ENV{TDR_NEW_VERSION}";}g;
  my $hashes =
    s{\Qhash = "$ENV{TDR_OLD_HASH}";\E}
     {hash = "$ENV{TDR_NEW_HASH}";}g;

  die "expected exactly one version and source hash\n"
    unless $versions == 1 && $hashes == 1;
' "$package_file"

echo "$lab_name: $old_version -> $new_version"