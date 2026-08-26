{
  lib,
  ...
}:

{
  home.activation = {
    replaceConfigs = lib.hm.dag.entryAfter [ "installPackages" ] ''
      if test -d ~/.config/FreeTube; then
        echo "Removing configs for: FreeTube"
        run rm -f $VERBOSE_ARG ~/.config/FreeTube/playlists.db
        run rm -f $VERBOSE_ARG ~/.config/FreeTube/profiles.db
        echo -e "Copying dotfiles for: FreeTube\n"
        run cp -r $VERBOSE_ARG ~/Documents/Repos/Notes/Media/Video/FreeTube/playlists.db ~/.config/FreeTube
        run cp -r $VERBOSE_ARG ~/Documents/Repos/Notes/Media/Video/FreeTube/profiles.db ~/.config/FreeTube
      fi
    '';
  };
}
