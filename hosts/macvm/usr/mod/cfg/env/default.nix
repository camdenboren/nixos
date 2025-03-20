{
  ...
}:

{
  imports = [
    # Common
    ../../../../../../common/usr/mod/cfg/env/home-manager.nix
    ../../../../../../common/usr/mod/cfg/env/nix-settings.nix
    ../../../../../../common/usr/mod/cfg/env/sessionVariables.nix

    # Host-specific
    ./files.nix
  ];
}
