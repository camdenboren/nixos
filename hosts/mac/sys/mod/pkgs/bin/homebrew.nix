{ ... }:

{
  # Enable homebrew and install specified casks
  homebrew = {
    enable = true;
    caskArgs.no_quarantine = true;
    casks = [
      "amethyst"
      "clickup"
      "eloston-chromium"
      "freecad"
      "freetube"
      "languagetool"
      "linearmouse"
      "mullvadvpn"
      "pearcleaner"
      "qdirstat"
      "tidal"
    ];
  };
}
