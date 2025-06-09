{ pkgs, ... }:

{
  users = {
    knownUsers = [ "camdenboren" ];
    users.camdenboren = {
      name = "camdenboren";
      home = "/Users/camdenboren";
      uid = 501;
      shell = pkgs.bashInteractive;
    };
  };

  system.primaryUser = "camdenboren";
}
