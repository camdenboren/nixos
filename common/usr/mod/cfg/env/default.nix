{
  pkgs,
  lib,
  system,
  hostname,
  ...
}:

let
  isLinux = lib.hasSuffix "-linux" system;
  isVM = lib.hasSuffix "vm" hostname;
in
{
  imports = [
    ./files.nix
    ./home-manager.nix
    ./nix-settings.nix
  ]
  ++ lib.optionals isLinux [
    ./sessionVariables.nix
  ]
  ++ lib.optionals isVM [
    ./xdg.nix
  ];

  # exposes pkgs installed via home-manager overlays
  # under config.home-manager.users.camdenboren.home.packageSet
  # useful for updating via `nix-update`
  options.home.packageSet = lib.mkOption {
    type = lib.types.raw;
  };
  config.home.packageSet = pkgs;
}
