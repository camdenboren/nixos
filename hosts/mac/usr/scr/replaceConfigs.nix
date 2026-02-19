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

  # remove all workflows
  echo -e ""
  if test -d ~/Library/Services/LaunchBitwarden.workflow; then
    echo "Removing LaunchBitwarden.workflow..."
    rm -rf ~/Library/Services/LaunchBitwarden.workflow
  fi
  if test -d ~/Library/Services/LaunchClickUp.workflow; then
    echo "Removing LaunchClickUp.workflow..."
    rm -rf ~/Library/Services/LaunchClickUp.workflow
  fi
  if test -d ~/Library/Services/LaunchFreeTube.workflow; then
    echo "Removing LaunchFreeTube.workflow..."
    rm -rf ~/Library/Services/LaunchFreeTube.workflow
  fi
  if test -d ~/Library/Services/LaunchGhostty.workflow; then
    echo "Removing LaunchGhostty.workflow..."
    rm -rf ~/Library/Services/LaunchGhostty.workflow
  fi
  if test -d ~/Library/Services/LaunchLibreWolf.workflow; then
    echo "Removing LaunchLibreWolf.workflow..."
    rm -rf ~/Library/Services/LaunchLibreWolf.workflow
  fi
  if test -d ~/Library/Services/LaunchMullvad.workflow; then
    echo "Removing LaunchMullvad.workflow..."
    rm -rf ~/Library/Services/LaunchMullvad.workflow
  fi
  if test -d ~/Library/Services/LaunchSlack.workflow; then
    echo "Removing LaunchSlack.workflow..."
    rm -rf ~/Library/Services/LaunchSlack.workflow
  fi
  if test -d ~/Library/Services/LaunchUTM.workflow; then
    echo "Removing LaunchUTM.workflow..."
    rm -rf ~/Library/Services/LaunchUTM.workflow
  fi
  if test -d ~/Library/Services/LaunchZed.workflow; then
    echo "Removing LaunchZed.workflow..."
    rm -rf ~/Library/Services/LaunchZed.workflow
  fi

  # copy workflow template for all apps
  echo -e "\nCopying LaunchApplication.workflow for each service..."
  cp -r ~/etc/nixos/hosts/mac/usr/dot/LaunchApplication.workflow \
    ~/Library/Services/LaunchBitwarden.workflow
  cp -r ~/etc/nixos/hosts/mac/usr/dot/LaunchApplication.workflow \
    ~/Library/Services/LaunchClickUp.workflow
  cp -r ~/etc/nixos/hosts/mac/usr/dot/LaunchApplication.workflow \
    ~/Library/Services/LaunchFreeTube.workflow
  cp -r ~/etc/nixos/hosts/mac/usr/dot/LaunchApplication.workflow \
    ~/Library/Services/LaunchGhostty.workflow
  cp -r ~/etc/nixos/hosts/mac/usr/dot/LaunchApplication.workflow \
    ~/Library/Services/LaunchLibreWolf.workflow
  cp -r ~/etc/nixos/hosts/mac/usr/dot/LaunchApplication.workflow \
    ~/Library/Services/LaunchMullvad.workflow
  cp -r ~/etc/nixos/hosts/mac/usr/dot/LaunchApplication.workflow \
    ~/Library/Services/LaunchSlack.workflow
  cp -r ~/etc/nixos/hosts/mac/usr/dot/LaunchApplication.workflow \
    ~/Library/Services/LaunchUTM.workflow
  cp -r ~/etc/nixos/hosts/mac/usr/dot/LaunchApplication.workflow \
    ~/Library/Services/LaunchZed.workflow

  # patch app paths for all apps
  echo -e "\nReplacing Applications' paths in all workflows..."
  ${pkgs.gnused}/bin/sed -i \
    's|~/Applications/Home Manager Apps/Application\.app|${pkgs.bitwarden-desktop}/Applications/Bitwarden.app|g' \
    ~/Library/Services/LaunchBitwarden.workflow/Contents/document.wflow
  ${pkgs.gnused}/bin/sed -i \
    's|~/Applications/Home Manager Apps/Application\.app|/Applications/ClickUp.app|g' \
    ~/Library/Services/LaunchClickUp.workflow/Contents/document.wflow
  ${pkgs.gnused}/bin/sed -i \
    's|~/Applications/Home Manager Apps/Application\.app|/Applications/FreeTube.app|g' \
    ~/Library/Services/LaunchFreeTube.workflow/Contents/document.wflow
  ${pkgs.gnused}/bin/sed -i \
    's|~/Applications/Home Manager Apps/Application\.app|${pkgs.ghostty-bin}/Applications/Ghostty.app|g' \
    ~/Library/Services/LaunchGhostty.workflow/Contents/document.wflow
  ${pkgs.gnused}/bin/sed -i \
    's|~/Applications/Home Manager Apps/Application\.app|${pkgs.librewolf}/Applications/LibreWolf.app|g' \
    ~/Library/Services/LaunchLibreWolf.workflow/Contents/document.wflow
  ${pkgs.gnused}/bin/sed -i \
    's|~/Applications/Home Manager Apps/Application\.app|/Applications/Mullvad VPN.app|g' \
    ~/Library/Services/LaunchMullvad.workflow/Contents/document.wflow
  ${pkgs.gnused}/bin/sed -i \
    's|~/Applications/Home Manager Apps/Application\.app|${pkgs.slack}/Applications/Slack.app|g' \
    ~/Library/Services/LaunchSlack.workflow/Contents/document.wflow
  ${pkgs.gnused}/bin/sed -i \
    's|~/Applications/Home Manager Apps/Application\.app|${pkgs.utm}/Applications/UTM.app|g' \
    ~/Library/Services/LaunchUTM.workflow/Contents/document.wflow
  ${pkgs.gnused}/bin/sed -i \
    's|~/Applications/Home Manager Apps/Application\.app|${pkgs.zed-editor}/Applications/Zed.app|g' \
    ~/Library/Services/LaunchZed.workflow/Contents/document.wflow

  # patch workflow name for all services
  echo -e "\nReplacing workflow names for all apps..."
  ${pkgs.gnused}/bin/sed -i \
    's|LaunchApplication|LaunchBitwarden|g' \
    ~/Library/Services/LaunchBitwarden.workflow/Contents/Info.plist
  ${pkgs.gnused}/bin/sed -i \
    's|LaunchApplication|LaunchClickUp|g' \
    ~/Library/Services/LaunchClickUp.workflow/Contents/Info.plist
  ${pkgs.gnused}/bin/sed -i \
    's|LaunchApplication|LaunchFreeTube|g' \
    ~/Library/Services/LaunchFreeTube.workflow/Contents/Info.plist
  ${pkgs.gnused}/bin/sed -i \
    's|LaunchApplication|LaunchGhostty|g' \
    ~/Library/Services/LaunchGhostty.workflow/Contents/Info.plist
  ${pkgs.gnused}/bin/sed -i \
    's|LaunchApplication|LaunchLibreWolf|g' \
    ~/Library/Services/LaunchLibreWolf.workflow/Contents/Info.plist
  ${pkgs.gnused}/bin/sed -i \
    's|LaunchApplication|LaunchMullvad|g' \
    ~/Library/Services/LaunchMullvad.workflow/Contents/Info.plist
  ${pkgs.gnused}/bin/sed -i \
    's|LaunchApplication|LaunchSlack|g' \
    ~/Library/Services/LaunchSlack.workflow/Contents/Info.plist
  ${pkgs.gnused}/bin/sed -i \
    's|LaunchApplication|LaunchUTM|g' \
    ~/Library/Services/LaunchUTM.workflow/Contents/Info.plist
  ${pkgs.gnused}/bin/sed -i \
    's|LaunchApplication|LaunchZed|g' \
    ~/Library/Services/LaunchZed.workflow/Contents/Info.plist
''
