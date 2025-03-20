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
      ./nix-settings.nix
    ]
    ++ lib.optionals isLinux [
      ./sessionVariables.nix
    ]
    ++ lib.optionals (hostname == "main" || hostname == "media") [
      ./etc.nix
    ];
}
