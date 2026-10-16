#!/usr/bin/env nix
#!nix shell nixpkgs#coreutils nixpkgs#gitMinimal nixpkgs#jq nixpkgs#perl nixpkgs#yarn-berry_4-fetcher.yarn-berry-fetcher --command bash

set -Eeuo pipefail

die() {
  echo "actual-cli updater: $*" >&2
  exit 1
}

owner="actualbudget"
repo="actual"

repo_root="$(git rev-parse --show-toplevel)"
package_dir="$repo_root/common/drv/actual-cli"
package_file="$package_dir/default.nix"
hashes_file="$package_dir/missing-hashes.json"
flake_attr="nixosConfigurations.main.pkgs.actual-cli"

[[ -f "$package_file" ]] || die "package file not found: $package_file"
[[ -f "$hashes_file" ]] || die "missing-hashes.json not found: $hashes_file"

old_version="$(
  perl -ne 'print "$1\n" if /^\s*version = "([^"]+)";/' "$package_file"
)"
old_src_hash="$(
  perl -ne '$fetch = 1 if /fetchFromGitHub/; if ($fetch && /^\s*hash = "([^"]+)";/) { print "$1\n"; exit; }' "$package_file"
)"
old_offline_hash="$(
  perl -ne '$fetch = 1 if /fetchYarnBerryDeps/; if ($fetch && /^\s*hash = "([^"]+)";/) { print "$1\n"; exit; }' "$package_file"
)"

[[ "$old_version" =~ ^[0-9]+([.][0-9]+)+$ ]] \
  || die "could not read the existing version"
[[ "$old_src_hash" == sha256-* ]] \
  || die "could not read the existing source hash"
[[ "$old_offline_hash" == sha256-* ]] \
  || die "could not read the existing offline cache hash"

new_version="$(
  git ls-remote --tags "https://github.com/${owner}/${repo}" \
    | perl -ne 'print "$1\n" if m{refs/tags/v([0-9.]+)$}' \
    | sort --version-sort \
    | tail --lines=1
)"

[[ "$new_version" =~ ^[0-9]+([.][0-9]+)+$ ]] \
  || die "could not determine the latest version"

if [[ "$old_version" == "$new_version" ]]; then
  echo "actual-cli is already up to date at $old_version"
  exit 0
fi

echo "actual-cli: $old_version -> $new_version"

new_src_hash="$(
  nix store prefetch-file \
    --json \
    --unpack \
    --name actualbudget-actual-source \
    "https://github.com/${owner}/${repo}/archive/refs/tags/v${new_version}.tar.gz" \
    | jq -er .hash
)"

[[ "$new_src_hash" == sha256-* ]] \
  || die "could not prefetch the new source"

backup_package="$(mktemp)"
backup_hashes="$(mktemp)"
cp -p "$package_file" "$backup_package"
cp -p "$hashes_file" "$backup_hashes"

cleanup() {
  local status=$?
  trap - EXIT

  if (( status != 0 )); then
    cp -p "$backup_package" "$package_file"
    cp -p "$backup_hashes" "$hashes_file"
  fi

  rm -f "$backup_package" "$backup_hashes"
  exit "$status"
}
trap cleanup EXIT

ACTUAL_CLI_OLD_VERSION="$old_version" \
ACTUAL_CLI_NEW_VERSION="$new_version" \
ACTUAL_CLI_OLD_SRC_HASH="$old_src_hash" \
ACTUAL_CLI_NEW_SRC_HASH="$new_src_hash" \
perl -0pi -e '
  my $versions =
    s{\Qversion = "$ENV{ACTUAL_CLI_OLD_VERSION}";\E}
     {version = "$ENV{ACTUAL_CLI_NEW_VERSION}";}g;
  my $hashes =
    s{\Qhash = "$ENV{ACTUAL_CLI_OLD_SRC_HASH}";\E}
     {hash = "$ENV{ACTUAL_CLI_NEW_SRC_HASH}";}g;

  die "expected exactly one version and source hash\n"
    unless $versions == 1 && $hashes == 1;
' "$package_file"

echo "Regenerating missing-hashes.json…"
src_path="$(
  nix build "$repo_root#${flake_attr}.src" --no-link --print-out-paths
)"
yarn-berry-fetcher missing-hashes "${src_path}/yarn.lock" >"$hashes_file"

echo "Updating offline cache hash…"
new_offline_hash="$(
  yarn-berry-fetcher prefetch "${src_path}/yarn.lock" "$hashes_file" \
    | perl -ne 'print "$1\n" if /(sha256-[A-Za-z0-9+\/=]+)/' \
    | tail --lines=1
)"

[[ "$new_offline_hash" == sha256-* ]] \
  || die "could not prefetch the offline cache"

ACTUAL_CLI_OLD_OFFLINE_HASH="$old_offline_hash" \
ACTUAL_CLI_NEW_OFFLINE_HASH="$new_offline_hash" \
perl -0pi -e '
  my $hashes =
    s{\Qhash = "$ENV{ACTUAL_CLI_OLD_OFFLINE_HASH}";\E}
     {hash = "$ENV{ACTUAL_CLI_NEW_OFFLINE_HASH}";}g;

  die "expected exactly one offline cache hash\n"
    unless $hashes == 1;
' "$package_file"

echo "actual-cli: $old_version -> $new_version"
