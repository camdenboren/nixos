{ pkgs }:

pkgs.writeShellScriptBin "check" ''
  set -euo pipefail
  shopt -s globstar
  failed() {
    echo -e "\n\033[1;31mSome checks failed.\033[0m"
    popd &> /dev/null
    exit 1
  }
  interrupted() {
    echo -e "\n\033[1;33mInterrupted.\033[0m"
    popd &> /dev/null
    exit 0
  }
  trap 'failed' ERR
  trap 'interrupted' INT

  pushd . &> /dev/null
  cd $NH_FLAKE

  echo -e "\033[1;33mstatix...\033[0m"
  statix check

  echo -e "\033[1;33mdeadnix...\033[0m"
  deadnix -f --exclude **/hardware-configuration.nix

  echo -e "\033[1;33mnix flake...\033[0m"
  nix flake check

  echo -e "\n\033[1;32mAll checks succeeded.\033[0m"
  popd &> /dev/null
''
