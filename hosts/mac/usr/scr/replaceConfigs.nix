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
''
