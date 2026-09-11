{ pkgs }:

pkgs.writeShellScriptBin "replaceConfigs" ''
  if ! test -f ~/.config/REAPER/reaper.ini; then
    mkdir -p ~/.config/REAPER
    cp -r ~/etc/nixos/hosts/main/usr/dot/reaper/reaper.ini ~/.config/REAPER
  fi
''
