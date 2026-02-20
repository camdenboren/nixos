{ pkgs }:

pkgs.writeScriptBin "replaceConfigs" ''
  if test -d ~/Library/Application\ Support/FreeTube; then
    echo "Removing configs for: freetube"
    rm -f ~/Library/Application\ Support/FreeTube/settings.db
    echo -e "Copying dotfiles for: freetube"
    cp -r ~/.config/FreeTube/settings.db ~/Library/Application\ Support/FreeTube
  fi

  if test -d ~/.config/linearmouse; then
    echo "Removing configs for: linearmouse"
    rm -f ~/.config/linearmouse/linearmouse.json
    echo -e "Copying dotfiles for: linearmouse"
    cp -r ~/etc/nixos/hosts/mac/usr/dot/linearmouse/linearmouse.json ~/.config/linearmouse
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
      rm -rf "$WORKFLOW_PATH"
    fi

    # copy workflow template
    cp -r "$TEMPLATE_PATH" "$WORKFLOW_PATH"

    # patch app path in workflow
    ${pkgs.gnused}/bin/sed -i \
      "s|~/Applications/Home Manager Apps/Application\.app|''${APP_PATH}/Applications/''${APP_NAME}.app|g" \
      "$WORKFLOW_PATH"/Contents/document.wflow

    # patch workflow name
    ${pkgs.gnused}/bin/sed -i \
      "s|LaunchApplication|Launch''${APP}|g" \
      "$WORKFLOW_PATH"/Contents/Info.plist
  }

  echo -e "Replacing Applications' workflows"
  replace_workflow Bitwarden ${pkgs.bitwarden-desktop}
  replace_workflow ClickUp
  replace_workflow FreeTube
  replace_workflow Ghostty ${pkgs.ghostty-bin}
  replace_workflow LibreWolf ${pkgs.librewolf}
  replace_workflow Mullvad "" "Mullvad VPN"
  replace_workflow Slack ${pkgs.slack}
  replace_workflow UTM ${pkgs.utm}
  replace_workflow Zed ${pkgs.zed-editor}
''
