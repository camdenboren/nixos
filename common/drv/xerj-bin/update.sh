#!/usr/bin/env nix
#!nix shell nixpkgs#curl nixpkgs#jq nixpkgs#perl nixpkgs#gitMinimal --command bash

set -Eeuo pipefail

die() {
  echo "xerj-bin updater: $*" >&2
  exit 1
}

repo_root="$(git rev-parse --show-toplevel)"
package_file="$repo_root/common/drv/xerj-bin/default.nix"
[[ -f "$package_file" ]] || die "package file not found: $package_file"
(( $# <= 1 )) || die "usage: $0 [version]"

old_version="$(
  perl -ne 'print "$1\n" if /^\s*version = "([^"]+)";/' "$package_file"
)"
[[ "$old_version" =~ ^[0-9]+[.][0-9]+[.][0-9]+(-rc[.][0-9]+)?$ ]] \
  || die "could not read the existing version"

release_api="https://api.github.com/repos/xerj-org/xerj/releases"
if (( $# == 1 )); then
  requested_version="${1#v}"
  [[ "$requested_version" =~ ^[0-9]+[.][0-9]+[.][0-9]+(-rc[.][0-9]+)?$ ]] \
    || die "invalid version: $1"
  release_api+="/tags/v${requested_version}"
else
  release_api+="?per_page=100"
fi

# Include release candidates: /releases/latest excludes prereleases.
release_json="$(
  curl --fail --silent --show-error --location --retry 3 \
    --user-agent 'nix-xerj-bin-updater/1' "$release_api" \
    | jq -c --arg current "$old_version" --argjson automatic "$(( $# == 0 ))" '
        def version_key:
          capture("^v?(?<major>[0-9]+)\\.(?<minor>[0-9]+)\\.(?<patch>[0-9]+)(-rc\\.(?<rc>[0-9]+))?$")
          | [(.major | tonumber), (.minor | tonumber), (.patch | tonumber),
             (if .rc == null then 1 else 0 end), ((.rc // "0") | tonumber)];
        (if type == "array" then . else [.] end)
        | map(select(.draft == false)
            | select(.tag_name | test("^v[0-9]+\\.[0-9]+\\.[0-9]+(-rc\\.[0-9]+)?$")))
        | if length == 0 then error("no matching release") else . end
        | map(select($automatic == 0 or (.tag_name | version_key) >= ($current | version_key)))
        | sort_by(.tag_name | version_key) | last
      '
)"
if [[ "$release_json" == null ]]; then
  echo "xerj-bin: no release newer than the current version $old_version"
  exit 0
fi
new_version="$(jq -er '.tag_name | ltrimstr("v")' <<<"$release_json")"

source_entries="$(
  perl -0ne '
    while (/^\s*target = "([^"]+)";\s*hash = "(sha256-[^"]+)";/mg) {
      print "$1\t$2\n";
    }
  ' "$package_file"
)"
[[ -n "$source_entries" ]] || die "could not read platform targets and hashes"

work_dir="$(mktemp -d)"
backup=""
cleanup() {
  local status=$?
  trap - EXIT
  if (( status != 0 )) && [[ -n "$backup" ]]; then
    cp -p "$backup" "$package_file"
  fi
  rm -rf "$work_dir"
  exit "$status"
}
trap cleanup EXIT

changed=false
while IFS=$'\t' read -r target old_hash; do
  archive_name="xerj-${new_version}-${target}.tar.gz"
  download_url="https://github.com/xerj-org/xerj/releases/download/v${new_version}/${archive_name}"
  jq -e --arg name "$archive_name" --arg url "$download_url" \
    '[.assets[] | select(.name == $name and .browser_download_url == $url)] | length == 1' \
    <<<"$release_json" >/dev/null \
    || die "release is missing exactly one expected asset: $archive_name"

  echo "Prefetching ${archive_name}…"
  new_hash="$(
    nix --extra-experimental-features nix-command \
      store prefetch-file --json --name "$archive_name" "$download_url" \
      | jq -er .hash
  )"
  [[ "$new_hash" == sha256-* ]] || die "could not prefetch $archive_name"
  printf '%s\t%s\n' "$target" "$new_hash" >>"$work_dir/hashes"
  [[ "$old_hash" == "$new_hash" ]] || changed=true
done <<<"$source_entries"

if [[ "$old_version" == "$new_version" && "$changed" == false ]]; then
  echo "xerj-bin is already up to date at $new_version"
  exit 0
fi

# Fetch every platform before editing, and restore the original on failure.
backup="$work_dir/default.nix"
cp -p "$package_file" "$backup"

XERJ_OLD_VERSION="$old_version" \
XERJ_NEW_VERSION="$new_version" \
XERJ_HASHES_FILE="$work_dir/hashes" \
perl -0pi -e '
  open my $fh, "<", $ENV{XERJ_HASHES_FILE} or die "open hashes: $!\n";
  my %hashes;
  {
    local $/ = "\n";
    while (my $line = <$fh>) {
      chomp $line;
      my ($target, $hash) = split /\t/, $line;
      die "duplicate target: $target\n" if exists $hashes{$target};
      $hashes{$target} = $hash;
    }
  }
  my $versions =
    s{\Qversion = "$ENV{XERJ_OLD_VERSION}";\E}
     {version = "$ENV{XERJ_NEW_VERSION}";}g;
  my $count = s{(target = "([^"]+)";\s*hash = ")[^"]+(";)}{
    my ($before, $target, $after) = ($1, $2, $3);
    my $hash = delete $hashes{$target};
    die "missing hash for $target\n" unless defined $hash;
    "$before$hash$after";
  }ge;
  die "expected one version and all platform hashes\n"
    unless $versions == 1 && $count > 0 && !keys %hashes;
' "$package_file"

nix-instantiate --parse "$package_file" >/dev/null
echo "xerj-bin: $old_version -> $new_version"
