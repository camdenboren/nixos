#!/usr/bin/env nix-shell
#!nix-shell -i bash -p curl-impersonate htmlq innoextract jq nix perl unzip gitMinimal

set -Eeuo pipefail

die() {
  echo "FreqEcho updater: $*" >&2
  exit 1
}

repo_root="$(git rev-parse --show-toplevel)"
package_file="$repo_root/hosts/main/usr/drv/freq-echo/default.nix"

[[ -f "$package_file" ]] || die "package file not found: $package_file"

mapfile -t download_urls < <(
  curl-impersonate \
    --compressed \
    --impersonate chrome146 \
    --fail \
    --silent \
    --show-error \
    --location \
    --retry 3 \
    'https://valhalladsp.com/demos-downloads/' \
    | htmlq \
      --attribute value \
      'input[name="download_url"][value*="/freqecho/ValhallaFreqEchoWin_"]'
)

(( ${#download_urls[@]} == 1 )) \
  || die "expected exactly one Windows FreqEcho download link"

download_url="${download_urls[0]}"

[[ "$download_url" =~ ^https://valhallaproduction[.]s3[.]us-west-2[.]amazonaws[.]com/freqecho/ValhallaFreqEchoWin_V([0-9]+(_[0-9]+)+)[.]zip$ ]] \
  || die "unexpected download URL: $download_url"

version_code="${BASH_REMATCH[1]}"
new_version="${version_code//_/.}"
expected_installer="ValhallaFreqEchoWin_V${version_code}.exe"

prefetch_json="$(
  nix --extra-experimental-features nix-command \
    store prefetch-file \
    --json \
    --name source \
    "$download_url"
)"
new_hash="$(jq -er .hash <<<"$prefetch_json")"
source_path="$(jq -er .storePath <<<"$prefetch_json")"

mapfile -t archive_entries < <(unzip -Z1 "$source_path")

(( ${#archive_entries[@]} == 1 )) \
  || die "expected exactly one file in the vendor archive"
[[ "${archive_entries[0]}" == "$expected_installer" ]] \
  || die "unexpected installer filename: ${archive_entries[0]}"

work_dir="$(mktemp -d)"
backup=""

cleanup() {
  local status=$?
  trap - EXIT

  if (( status != 0 )) && [[ -n "$backup" ]]; then
    cp -p "$backup" "$package_file"
  fi

  [[ -z "$backup" ]] || rm -f "$backup"
  rm -rf "$work_dir"
  exit "$status"
}
trap cleanup EXIT

unzip -q "$source_path" -d "$work_dir"
installer_listing="$(innoextract --list "$work_dir/$expected_installer" 2>&1)"

[[ "$installer_listing" == *'Listing "ValhallaFreqEcho"'* ]] \
  || die "installer product name changed"
[[ "$installer_listing" == *'"code$GetVST3Dir/ValhallaFreqEcho.vst3"'* ]] \
  || die 'installer no longer contains code$GetVST3Dir/ValhallaFreqEcho.vst3'

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
  echo "FreqEcho is already up to date at $new_version"
  exit 0
fi

backup="$(mktemp)"
cp -p "$package_file" "$backup"

FREQECHO_OLD_VERSION="$old_version" \
FREQECHO_NEW_VERSION="$new_version" \
FREQECHO_OLD_HASH="$old_hash" \
FREQECHO_NEW_HASH="$new_hash" \
perl -0pi -e '
  my $versions =
    s{\Qversion = "$ENV{FREQECHO_OLD_VERSION}";\E}
     {version = "$ENV{FREQECHO_NEW_VERSION}";}g;
  my $hashes =
    s{\Qhash = "$ENV{FREQECHO_OLD_HASH}";\E}
     {hash = "$ENV{FREQECHO_NEW_HASH}";}g;

  die "expected exactly one version and source hash\n"
    unless $versions == 1 && $hashes == 1;
' "$package_file"

echo "FreqEcho: $old_version -> $new_version"
