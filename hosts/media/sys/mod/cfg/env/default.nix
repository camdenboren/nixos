{ ... }:

{
  imports = [
    # Common
    ../../../../../../common/sys/mod/cfg/env/nix-settings.nix
    ../../../../../../common/sys/mod/cfg/env/sessionVariables.nix

    # Host-specific
    ./etc.nix
  ];
}
