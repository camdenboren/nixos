_:

{
  # Enable homebrew and install specified casks
  homebrew = {
    enable = true;
    casks = [
      "amethyst"
      "bitwarden"
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
      "ollama-app"
      "pearcleaner"
      "qdirstat"
      "readest"
      "tailscale-app"
      "zoom"
    ];
    greedyCasks = true;
  };
}
