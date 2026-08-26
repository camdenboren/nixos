{
  pkgs,
  pkgs-stable,
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
      lynx
      # unstable is broken on darwin - https://hydra.nixos.org/build/333610201
      #statix
    ]
    ++ lib.optionals (hostname == "main") [
      quickemu
    ]
    ++ lib.optionals isDarwin [
      #jetbrains.idea-oss - now uses jetbrains jdk which has been broken on darwin for years
      utm
      wireshark
    ]
    ++ (with pkgs-stable; [
      statix
    ]);

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
