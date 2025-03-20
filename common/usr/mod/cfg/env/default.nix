{
  lib,
  system,
  hostname,
  ...
}:

let
  isLinux = lib.hasSuffix "-linux" system;
in
{
  imports =
    [
      ./home-manager.nix
      ./nix-settings.nix
    ]
    ++ lib.optionals isLinux [
      ./sessionVariables.nix
    ]
    ++ lib.optionals (hostname == "main" || hostname == "media") [
      ./xdg.nix
    ];
}
