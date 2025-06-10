{
  pkgs,
  lib,
  system,
  ...
}:

let
  isDarwin = lib.hasSuffix "-darwin" system;
in
{
  programs.ghostty =
    lib.recursiveUpdate
      # all platforms
      {
        enable = true;
      }

      # macOS-only
      (
        lib.optionalAttrs isDarwin {
          package = pkgs.ghostty-bin;
        }
      );
}
