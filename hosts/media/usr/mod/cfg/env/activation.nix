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
        $DRY_RUN_CMD echo -e $VERBOSE_ARG "Copying dotfiles for: FreeTube\n"
        $DRY_RUN_CMD cp -r $VERBOSE_ARG ~/Documents/Repos/Notes/Media/Video/FreeTube/playlists.db ~/.config/FreeTube
        $DRY_RUN_CMD cp -r $VERBOSE_ARG ~/Documents/Repos/Notes/Media/Video/FreeTube/profiles.db ~/.config/FreeTube
      fi
    '';
  };
}
