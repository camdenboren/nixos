{ pkgs }:

pkgs.writeShellScriptBin "replaceConfigs" ''
  if test -d ~/.config/FreeTube; then
    echo "Removing configs for: FreeTube"
    rm -f ~/.config/FreeTube/settings.db
    rm -f ~/.config/FreeTube/playlists.db
    rm -f ~/.config/FreeTube/profiles.db
    echo -e "Copying dotfiles for: FreeTube\n"
    cp -r ~/etc/nixos/hosts/media/usr/dot/FreeTube/settings.db ~/.config/FreeTube
    cp -r ~/Documents/Repos/Notes/Media/Video/FreeTube/playlists.db ~/.config/FreeTube
    cp -r ~/Documents/Repos/Notes/Media/Video/FreeTube/profiles.db ~/.config/FreeTube
  fi

  if test -d ~/.config/tidal-hifi; then
    echo "Removing configs for: tidal-hifi"
    rm -f ~/.config/tidal-hifi/config.json
    rm -f ~/.config/tidal-hifi/Preferences
    echo -e "Copying dotfiles for: tidal-hifi\n"
    cp -r ~/etc/nixos/common/usr/dot/tidal-hifi/config.json ~/.config/tidal-hifi
    cp -r ~/etc/nixos/common/usr/dot/tidal-hifi/Preferences ~/.config/tidal-hifi
  fi
''
