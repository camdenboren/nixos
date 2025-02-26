{
  pkgs,
  lib,
  system,
  ...
}:

let
  isDarwin = lib.hasSuffix "-darwin" system;
  empty = pkgs.emptyDirectory.overrideAttrs (old: {
    meta = (old.meta or { }) // {
      mainProgram = "ghostty";
    };
  });
in
{
  programs.ghostty =
    lib.recursiveUpdate
      # all platforms
      {
        enable = true;
      }

      # macOS-only
      # ghostty isn't available for darwin on nixpkgs, see homebrew.nix
      (
        lib.optionalAttrs isDarwin {
          package = empty;
        }
      );
}
