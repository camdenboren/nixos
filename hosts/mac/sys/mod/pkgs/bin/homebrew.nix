_:

{
  # Enable homebrew and install specified casks
  homebrew = {
    enable = true;
    casks = [
      "amethyst"
      "clickup"
      "ungoogled-chromium"
      "freecad"
      "freetube"
      "gimp"
      "inkscape"
      "intellij-idea"
      "languagetool-desktop"
      "linearmouse"
      "mullvad-vpn"
      "pearcleaner"
      "qdirstat"
      "readest"
      "tailscale-app"
      "zoom"
    ];
    greedyCasks = true;
  };
}
