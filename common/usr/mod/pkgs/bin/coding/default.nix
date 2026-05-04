{
  pkgs,
  lib,
  system,
  hostname,
  ...
}:

let
  isDarwin = lib.hasSuffix "-darwin" system;
in
{
  home.packages =
    with pkgs;
    [
      # Programming
      deadnix
      nixd
      nixfmt
      harper
      fd
      lynx
      statix
    ]
    ++ lib.optionals (hostname == "main") [
      quickemu
    ]
    ++ lib.optionals isDarwin [
      #jetbrains.idea-oss - now uses jetbrains jdk which has been broken on darwin for years
      utm
      (wireshark.overrideAttrs {
        src = pkgs.fetchFromGitLab {
          repo = "wireshark";
          owner = "wireshark";
          tag = "v4.6.5";
          hash = "sha256-Zvrwxjp4LK2J3QnxmPxKKrU01YHQvPyp54UWzeGNCjA=";
        };
      })
    ];

  imports = [
    ./bash.nix
    ./ghostty.nix
    ./git.nix
    ./lazygit.nix
    ./neovim.nix
    ./zed.nix
  ]
  ++ lib.optionals isDarwin [
    ./fonts.nix
  ];
}
