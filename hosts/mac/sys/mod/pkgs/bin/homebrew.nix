{ ... }:

{
  # Enable homebrew and install specified casks
  homebrew = {
    enable = true;
    caskArgs.no_quarantine = true;
    casks = [
      "amethyst"
      "bitwarden"
      "clickup"
      "desktoppr"
      "eloston-chromium"
      "freecad"
      "freetube"
      "ghostty"
      "languagetool"
      "linearmouse"
      "mullvadvpn"
      "pearcleaner"
      "qdirstat"
      "tidal"
    ];
  };
}
