#!/usr/bin/env bash

update_pkg() {
  local name=$1
  local type=$2
  local os=$3
  local host=${4:-main}

  case $type in
    system)
      nix-update ${os}Configurations.$host.pkgs.$name --flake --use-update-script
      ;;
    user)
      nix-update ${os}Configurations.$host.config.home-manager.users.camdenboren.home.packageSet.$name --flake --use-update-script
      ;;
    *)
      echo "Unknown system type: $type" >&2
      return 1
      ;;
  esac
}

update_pkg "$@"
