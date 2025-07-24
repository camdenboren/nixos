{
  lib,
  ...
}:

{
  home.activation = {
    replaceConfigs = lib.hm.dag.entryAfter [ "installPackages" ] ''
      if test -d ~/.config/FreeTube; then
        $DRY_RUN_CMD echo $VERBOSE_ARG "Removing configs for: FreeTube"
        $DRY_RUN_CMD rm -f $VERBOSE_ARG ~/.config/FreeTube/playlists.db
        $DRY_RUN_CMD rm -f $VERBOSE_ARG ~/.config/FreeTube/profiles.db
        $DRY_RUN_CMD echo -e $VERBOSE_ARG "Copying dotfiles for: FreeTube\n" ~/Documents/Repos/Notes/Media/Video/FreeTube/playlists.db ~/.config/FreeTube
        $DRY_RUN_CMD cp -r $VERBOSE_ARG ~/Documents/Repos/Notes/Media/Video/FreeTube/profiles.db ~/.config/FreeTube
      fi

      if test -d ~/.config/tidal-hifi; then
        $DRY_RUN_CMD echo $VERBOSE_ARG "Removing configs for: tidal-hifi"
        $DRY_RUN_CMD rm -f $VERBOSE_ARG ~/.config/tidal-hifi/config.json
        $DRY_RUN_CMD rm -f $VERBOSE_ARG ~/.config/tidal-hifi/Preferences
        $DRY_RUN_CMD echo -e $VERBOSE_ARG "Copying dotfiles for: tidal-hifi\n"
        $DRY_RUN_CMD cp -r $VERBOSE_ARG ~/etc/nixos/common/usr/dot/tidal-hifi/config.json ~/.config/tidal-hifi
        $DRY_RUN_CMD cp -r $VERBOSE_ARG ~/etc/nixos/common/usr/dot/tidal-hifi/Preferences ~/.config/tidal-hifi
      fi

      if ! test -f ~/.config/REAPER/reaper.ini; then
        $DRY_RUN_CMD mkdir -p $VERBOSE_ARG ~/.config/REAPER
        $DRY_RUN_CMD cp -r $VERBOSE_ARG ~/etc/nixos/hosts/main/usr/dot/reaper/reaper.ini ~/.config/REAPER
      fi
    '';
  };
}
