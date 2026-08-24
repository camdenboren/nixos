#!/usr/bin/env nix-shell
#!nix-shell -i bash -p curl htmlq innoextract jq nix perl gitMinimal

set -Eeuo pipefail

die() {
  echo "SPAN updater: $*" >&2
  exit 1
}

repo_root="$(git rev-parse --show-toplevel)"
package_file="$repo_root/hosts/main/usr/drv/span/default.nix"

[[ -f "$package_file" ]] || die "package file not found: $package_file"

mapfile -t download_urls < <(
  curl \
    --fail \
    --silent \
    --show-error \
    --location \
    --retry 3 \
    --user-agent 'nix-span-updater/1' \
    'https://www.voxengo.com/product/span/' \
    | htmlq --attribute href 'a[href*="VoxengoSPAN_"][href$="_setup.exe"]'
)

(( ${#download_urls[@]} == 1 )) \
  || die "expected exactly one Windows installer link"

download_url="${download_urls[0]}"

if [[ "$download_url" == /files/* ]]; then
  download_url="https://www.voxengo.com$download_url"
fi

[[ "$download_url" =~ ^https://www[.]voxengo[.]com/files/VoxengoSPAN_([0-9]+)_Win32_64_VST_VST3_AAX_setup[.]exe$ ]] \
  || die "unexpected download URL: $download_url"

filename_version="${BASH_REMATCH[1]}"
prefetch_json="$(
  nix --extra-experimental-features nix-command \
    store prefetch-file \
    --json \
    --name source \
    "$download_url"
)"
new_hash="$(jq -er .hash <<<"$prefetch_json")"
source_path="$(jq -er .storePath <<<"$prefetch_json")"

installer_listing="$(innoextract --list "$source_path" 2>&1)"
mapfile -t installer_versions < <(
  perl -ne 'print "$1\n" if /^Listing "Voxengo SPAN ([0-9]+(?:\.[0-9]+)+)"/' \
    <<<"$installer_listing"
)

(( ${#installer_versions[@]} == 1 )) \
  || die "could not read exactly one version from the installer"

new_version="${installer_versions[0]}"

[[ "${new_version//./}" == "$filename_version" ]] \
  || die "installer version and filename disagree"
[[ "$installer_listing" == *'"cf64/VST3/SPAN.vst3"'* ]] \
  || die "installer no longer contains cf64/VST3/SPAN.vst3"

old_version="$(
  perl -ne 'print "$1\n" if /^\s*version = "([^"]+)";/' "$package_file"
)"
old_hash="$(
  perl -ne 'print "$1\n" if /^\s*hash = "([^"]+)";/' "$package_file"
)"

[[ "$old_version" =~ ^[0-9]+([.][0-9]+)+$ ]] \
  || die "could not read the existing version"
[[ "$old_hash" == sha256-* ]] \
  || die "could not read the existing source hash"

if [[ "$old_version" == "$new_version" && "$old_hash" == "$new_hash" ]]; then
  echo "SPAN is already up to date at $new_version"
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

SPAN_OLD_VERSION="$old_version" \
SPAN_NEW_VERSION="$new_version" \
SPAN_OLD_HASH="$old_hash" \
SPAN_NEW_HASH="$new_hash" \
perl -0pi -e '
  my $versions =
    s{\Qversion = "$ENV{SPAN_OLD_VERSION}";\E}
     {version = "$ENV{SPAN_NEW_VERSION}";}g;
  my $hashes =
    s{\Qhash = "$ENV{SPAN_OLD_HASH}";\E}
     {hash = "$ENV{SPAN_NEW_HASH}";}g;

  die "expected exactly one version and source hash\n"
    unless $versions == 1 && $hashes == 1;
' "$package_file"

echo "SPAN: $old_version -> $new_version"
