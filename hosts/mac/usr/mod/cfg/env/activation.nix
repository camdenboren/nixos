{
  pkgs,
  lib,
  ...
}:

{
  home.activation = {
    replaceConfigs = lib.hm.dag.entryAfter [ "installPackages" ] ''
      if test -d ~/Library/Application\ Support/FreeTube; then
        $DRY_RUN_CMD echo $VERBOSE_ARG "Removing configs for: freetube"
        $DRY_RUN_CMD rm -f $VERBOSE_ARG ~/Library/Application\ Support/FreeTube/settings.db
        $DRY_RUN_CMD echo -e $VERBOSE_ARG "Copying dotfiles for: freetube"
        $DRY_RUN_CMD cp -r $VERBOSE_ARG ~/.config/FreeTube/settings.db ~/Library/Application\ Support/FreeTube
      fi

      if test -d ~/.config/linearmouse; then
        $DRY_RUN_CMD echo $VERBOSE_ARG "Removing configs for: linearmouse"
        $DRY_RUN_CMD rm -f $VERBOSE_ARG ~/.config/linearmouse/linearmouse.json
        $DRY_RUN_CMD echo -e $VERBOSE_ARG "Copying dotfiles for: linearmouse"
        $DRY_RUN_CMD cp -r $VERBOSE_ARG ~/etc/nixos/hosts/mac/usr/dot/linearmouse/linearmouse.json ~/.config/linearmouse
      fi

      # replace the app's corresponding workflow via a copied template, patching
      # w/ sed
      # the shortcuts for these workflows are created in `hosts/mac/sys/mod/cfg/def/macos.nix`
      replace_workflow() {
        local APP="$1"
        local APP_PATH="''${2:-}"
        local APP_NAME="''${3:-"$APP"}"
        local WORKFLOW_PATH=~/Library/Services/Launch"$APP".workflow
        local TEMPLATE_PATH=~/etc/nixos/hosts/mac/usr/dot/LaunchApplication.workflow

        # remove old workflow
        if test -d "$WORKFLOW_PATH"; then
          $DRY_RUN_CMD rm -rf $VERBOSE_ARG "$WORKFLOW_PATH"
        fi

        # copy workflow template
        $DRY_RUN_CMD cp -r $VERBOSE_ARG "$TEMPLATE_PATH" "$WORKFLOW_PATH"

        # patch app path in workflow
        $DRY_RUN_CMD ${pkgs.gnused}/bin/sed -i $VERBOSE_ARG \
          "s|~/Applications/Home Manager Apps/Application\.app|''${APP_PATH}/Applications/''${APP_NAME}.app|g" \
          "$WORKFLOW_PATH"/Contents/document.wflow

        # patch workflow name
        $DRY_RUN_CMD ${pkgs.gnused}/bin/sed -i $VERBOSE_ARG \
          "s|LaunchApplication|Launch''${APP}|g" \
          "$WORKFLOW_PATH"/Contents/Info.plist
      }

      $DRY_RUN_CMD echo -e $VERBOSE_ARG "Replacing Applications' workflows"
      replace_workflow Bitwarden ${pkgs.bitwarden-desktop}
      replace_workflow ClickUp
      replace_workflow FreeTube
      replace_workflow Ghostty ${pkgs.ghostty-bin}
      replace_workflow LibreWolf ${pkgs.librewolf}
      replace_workflow Mullvad "" "Mullvad VPN"
      replace_workflow Slack ${pkgs.slack}
      replace_workflow UTM ${pkgs.utm}
      replace_workflow Zed ${pkgs.zed-editor}
    '';
  };
}
