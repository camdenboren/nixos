{ ... }:

{
  # Enable homebrew and install specified casks
  homebrew = {
    enable = true;
    caskArgs.no_quarantine = true;
    casks = [
      "amethyst"
      "clickup"
      "ungoogled-chromium"
      "freecad"
      "freetube"
      "gimp"
      "languagetool-desktop"
      "linearmouse"
      "mullvad-vpn"
      "ollama-app"
      "pearcleaner"
      "qdirstat"
      "tailscale-app"
      "tidal"
      "zoom"
    ];
    greedyCasks = true;
  };
}
