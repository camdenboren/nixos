#!/usr/bin/env nix
#!nix shell nixpkgs#cacert nixpkgs#gitMinimal nixpkgs#python3 --command bash

set -euo pipefail

repo_root="$(git rev-parse --show-toplevel)"
exec python3 "$repo_root/common/drv/maudioplugins/update.py"
