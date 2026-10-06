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
      nix-update
      harper
      fd
      jq
      lynx
      unzip
      zip
      statix
    ]
    ++ lib.optionals (hostname == "main") [
      quickemu
    ]
    ++ lib.optionals isDarwin [
      #jetbrains.idea-oss - now uses jetbrains jdk which has been broken on darwin for years
      utm
      wireshark
    ];

  imports = [
    ./agents.nix
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
