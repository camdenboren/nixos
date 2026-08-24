#!/usr/bin/env nix-shell
#!nix-shell -i bash -p curl htmlq jq nix perl gitMinimal

set -Eeuo pipefail

die() {
  echo "LoudMax updater: $*" >&2
  exit 1
}

repo_root="$(git rev-parse --show-toplevel)"
package_file="$repo_root/hosts/main/usr/drv/loudmax/default.nix"

[[ -f "$package_file" ]] || die "package file not found: $package_file"

mapfile -t download_urls < <(
  curl \
    --fail \
    --silent \
    --show-error \
    --location \
    --retry 3 \
    --user-agent 'nix-loudmax-updater/1' \
    'https://loudmax.blogspot.com/' \
    | htmlq --attribute href 'a[href*="_Linux_x86_LADSPA.tar.gz"]'
)

(( ${#download_urls[@]} == 1 )) \
  || die "expected exactly one Linux LADSPA download link"

download_url="${download_urls[0]}"
archive_name="${download_url%%\?*}"
archive_name="${archive_name##*/}"

[[ "$archive_name" =~ ^LoudMax_(v[0-9]+(_[0-9]+)+)_Linux_x86_LADSPA[.]tar[.]gz$ ]] \
  || die "could not derive a version from $download_url"

version_code="${BASH_REMATCH[1]}"
new_version="${version_code//_/.}"

[[ "$download_url" =~ ^https://www[.]dropbox[.]com/scl/fi/[[:alnum:]]+/${archive_name}[?] ]] \
  || die "unexpected download URL: $download_url"

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

[[ "$old_version" =~ ^v[0-9]+([.][0-9]+)+$ ]] \
  || die "could not read the existing version"
[[ "$old_url" == https://www.dropbox.com/* ]] \
  || die "could not read the existing source URL"
[[ "$old_hash" == sha256-* ]] \
  || die "could not read the existing source hash"

if [[ "$old_version" == "$new_version" && "$old_url" == "$download_url" && "$old_hash" == "$new_hash" ]]; then
  echo "LoudMax is already up to date at $new_version"
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

LOUDMAX_OLD_VERSION="$old_version" \
LOUDMAX_NEW_VERSION="$new_version" \
LOUDMAX_OLD_URL="$old_url" \
LOUDMAX_NEW_URL="$download_url" \
LOUDMAX_OLD_HASH="$old_hash" \
LOUDMAX_NEW_HASH="$new_hash" \
perl -0pi -e '
  my $versions =
    s{\Qversion = "$ENV{LOUDMAX_OLD_VERSION}";\E}
     {version = "$ENV{LOUDMAX_NEW_VERSION}";}g;
  my $urls =
    s{\Qurl = "$ENV{LOUDMAX_OLD_URL}";\E}
     {url = "$ENV{LOUDMAX_NEW_URL}";}g;
  my $hashes =
    s{\Qhash = "$ENV{LOUDMAX_OLD_HASH}";\E}
     {hash = "$ENV{LOUDMAX_NEW_HASH}";}g;

  die "expected exactly one version, source URL, and source hash\n"
    unless $versions == 1 && $urls == 1 && $hashes == 1;
' "$package_file"

echo "LoudMax: $old_version -> $new_version"
