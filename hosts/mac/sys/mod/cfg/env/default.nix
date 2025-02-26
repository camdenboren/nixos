{ ... }:

{
  imports = [
    # Common
    ../../../../../../common/sys/mod/cfg/env/nix-settings.nix

    # Host-specific
    ./activation.nix
    ./platform.nix
    ./sessionVariables.nix
  ];
}
