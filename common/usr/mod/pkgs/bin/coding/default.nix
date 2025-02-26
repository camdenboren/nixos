{
  pkgs,
  pkgs-stable,
  lib,
  system,
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
    ++ lib.optionals (!isDarwin) [
      pkgs-stable.quickemu # dep ceph build broken as of 12/23: https://hydra.nixos.org/build/284315177
    ]
    ++ lib.optionals isDarwin [
      jetbrains.idea-community
      ollama
      utm
      wireshark
    ];

  imports =
    [
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
