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
      nix-init
      nix-update
      gh
      harper
      fd
      jq
      lynx
      statix
    ]
    ++ lib.optionals (hostname == "main") [
      quickemu
    ]
    ++ lib.optionals isDarwin [
      #jetbrains.idea-oss - now uses jetbrains jdk which has been broken on darwin for years
      #utm
      wireshark
    ]
    ++ lib.optionals isDarwin (
      with pkgs-stable;
      [
        utm
      ]
    );

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
