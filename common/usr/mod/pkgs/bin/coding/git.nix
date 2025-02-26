{
  system,
  pkgs,
  lib,
  ...
}:

{
  programs.git = {
    enable = true;
    userName = "camdenboren";
    userEmail = "9UtEfABpSSrV3g.code@mailbox.org";
    aliases = {
      find = "log --name-status -i --grep";
    };
    extraConfig = {
      credential.helper =
        if lib.hasSuffix "-linux" system then
          "${pkgs.git.override { withLibsecret = true; }}/bin/git-credential-libsecret"
        else
          "osxkeychain";
    };
  };
}
