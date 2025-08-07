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
      nixd
      nixfmt-rfc-style
      fd
      lynx
    ]
    ++ lib.optionals (hostname == "main") [
      quickemu
    ]
    ++ lib.optionals isDarwin [
      jetbrains.idea-community
      ollama
      utm
      wireshark
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
