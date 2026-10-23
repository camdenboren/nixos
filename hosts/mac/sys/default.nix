{ ... }:

{
  imports = [
    ../../../common/secrets
    ./mod/cfg
    ./mod/pkgs
  ];

  system.stateVersion = 6;
}
