{
  lib,
  ...
}:
# not working, only for reference
# seems to not play nice w/ line 9's \ stuff when run from home.activation
{
  home.activation = {
    replaceConfigs = lib.hm.dag.entryAfter [ "installPackages" ] ''
      if test -d ~/.config/FreeTube; then
        $DRY_RUN_CMD echo $VERBOSE_ARG "Removing configs for: FreeTube"
        $DRY_RUN_CMD rm -f $VERBOSE_ARG ~/Library/Application\ Support/FreeTube/settings.db
        $DRY_RUN_CMD echo -e $VERBOSE_ARG "Copying dotfiles for: FreeTube\n"
        $DRY_RUN_CMD cp -r $VERBOSE_ARG ~/etc/nixos/common/usr/dot/FreeTube/settings.db ~/Library/Application\ Support/FreeTube
      fi
    '';
  };
}
