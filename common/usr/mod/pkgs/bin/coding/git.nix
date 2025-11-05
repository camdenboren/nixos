{
  system,
  pkgs,
  lib,
  ...
}:

{
  programs.git = {
    enable = true;

    settings = {
      user = {
        name = "camdenboren";
        email = "9UtEfABpSSrV3g.code@mailbox.org";
      };

      alias = {
        find = "log --name-status -i --grep";
      };

      credential.helper =
        if lib.hasSuffix "-linux" system then
          "${pkgs.git.override { withLibsecret = true; }}/bin/git-credential-libsecret"
        else
          "osxkeychain";
      "remote \"origin\"".prune = true;
    };
  };
}
