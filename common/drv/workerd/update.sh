#! /usr/bin/env nix-shell
#! nix-shell -i bash -p gnused nix nodejs gitMinimal

set -euo pipefail
repo_root=$(git rev-parse --show-toplevel)
cd "$repo_root/common/drv/workerd"

version=$(npm view workerd version)

if [[ "$UPDATE_NIX_OLD_VERSION" == "$version" ]]; then
    echo "Already up to date!"
    exit 0
fi

declare -A npmPlatformOf=(
    [x86_64-linux]=linux-64
    [aarch64-linux]=linux-arm64
    [aarch64-darwin]=darwin-arm64
)

sed -i 's#version = "[^"]*"#version = "'"$version"'"#' default.nix

for system in "${!npmPlatformOf[@]}"; do
    npmPlatform=${npmPlatformOf[$system]}
    url="https://registry.npmjs.org/@cloudflare/workerd-${npmPlatform}/-/workerd-${npmPlatform}-${version}.tgz"
    hash=$(nix-hash --to-sri --type sha256 "$(nix-prefetch-url --quiet "$url")")
    sed -i "/${system} = \"sha256-/s#\"sha256-[^\"]*\"#\"${hash}\"#" default.nix
done
