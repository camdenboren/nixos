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
      "languagetool-desktop"
      "linearmouse"
      "mullvad-vpn"
      "pearcleaner"
      "qdirstat"
      "tidal"
    ];
  };
}
