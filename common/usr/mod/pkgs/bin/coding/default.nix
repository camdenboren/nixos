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
      utm
      (wireshark.overrideAttrs (
        o:
        let
          fixExtcapDir = builtins.replaceStrings [ "lib/wireshark/extcap" ] [ "libexec/wireshark/extcap" ];
        in
        {
          # Wireshark depends on Qt 6, which requires an SDK >= 12 on macOS
          # This is specified on Qt 6 itself, but not correctly propagated
          buildInputs = o.buildInputs or [ ] ++ [
            pkgs.apple-sdk_15
            (pkgs.darwinMinVersionHook "12.0")
          ];
          postInstall = fixExtcapDir o.postInstall or "";
          postFixup = fixExtcapDir o.postFixup or "";
        }
      ))
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
