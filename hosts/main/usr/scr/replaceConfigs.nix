{ pkgs }:

pkgs.writeShellScriptBin "replaceConfigs" ''
  if test -d ~/.config/FreeTube; then
    echo "Removing configs for: FreeTube"
    rm -f ~/.config/FreeTube/playlists.db
    rm -f ~/.config/FreeTube/profiles.db
    echo -e "Copying dotfiles for: FreeTube\n"
    cp -r ~/Documents/Repos/Notes/Media/Video/FreeTube/playlists.db ~/.config/FreeTube
    cp -r ~/Documents/Repos/Notes/Media/Video/FreeTube/profiles.db ~/.config/FreeTube
  fi

  if ! test -f ~/.config/REAPER/reaper.ini; then
    mkdir -p ~/.config/REAPER
    cp -r ~/etc/nixos/hosts/main/usr/dot/reaper/reaper.ini ~/.config/REAPER
  fi
''
