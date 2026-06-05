_:

{
  # Enable homebrew and install specified casks
  homebrew = {
    enable = true;
    caskArgs.no_quarantine = true;
    casks = [
      "amethyst"
      "bitwarden"
      "clickup"
      "ungoogled-chromium"
      "freecad"
      "freetube"
      "gimp"
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
