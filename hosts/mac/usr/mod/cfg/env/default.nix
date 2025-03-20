{ ... }:

{
  imports = [
    # Common
    ../../../../../../common/usr/mod/cfg/env/home-manager.nix
    ../../../../../../common/usr/mod/cfg/env/nix-settings.nix

    # Host-specific
    #./activation.nix
    ./files.nix
    ./sessionVariables.nix
  ];
}
