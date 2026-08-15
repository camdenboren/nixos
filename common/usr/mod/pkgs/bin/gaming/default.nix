{
  pkgs,
  lib,
  hostname,
  ...
}:

{
  home.packages =
    with pkgs;
    [
      # Gaming
      protonup-qt
      protontricks
    ]
    ++ lib.optionals (hostname == "media") [
      cemu
    ];

  imports = [
    ./mangohud.nix
  ];
}
