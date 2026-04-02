{ pkgs }:

pkgs.writeShellScriptBin "dev" ''
  currentDirectory=$(pwd)
  while getopts 'cjpr' OPTION; do
    case "$OPTION" in
      c)
        echo "Adding C flake to: $currentDirectory"
        cp -r ~/etc/nixos/common/usr/dev/c/flake.nix $currentDirectory
        ;;
      j)
        echo "Adding Java flake to: $currentDirectory"
        cp -r ~/etc/nixos/common/usr/dev/java/flake.nix $currentDirectory
        ;;
      p)
        echo "Adding Python flake to: $currentDirectory"
        cp -r ~/etc/nixos/common/usr/dev/python/flake.nix $currentDirectory
        ;;
      r)
        echo "Adding Rust flake to: $currentDirectory"
        cp -r ~/etc/nixos/common/usr/dev/rust/flake.nix $currentDirectory
        ;;
      ?)
        echo "script usage: [-c] [-j] [-p] [-r]" >&2
        exit 1
        ;;
    esac
  done
  if [ "$OPTIND" -eq 1 ]; then
    echo "Run this w/ -cjpr to add correct dev-env to the current directory. Use dev-env w/ nix develop"
  fi
  shift "$(($OPTIND -1))"
''
