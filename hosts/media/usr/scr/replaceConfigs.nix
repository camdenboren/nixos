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
''
