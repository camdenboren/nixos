{
  lib,
  system,
  hostname,
  rice,
  ...
}:

let
  isLinux = lib.hasSuffix "-linux" system;
in
{
  imports =
    [
      ./keybinds.nix
      ./rice.nix
    ]
    ++ lib.optionals isLinux [
      ./gnome.nix
    ]
    ++ lib.optionals (hostname == "main" || hostname == "media") [
      ./defaultApplications.nix
    ];

  keybinds.enable = true;
  inherit rice;
}
