{ lib, pkgs, ... }:

{
  home.packages = with pkgs; [
    # Office
    (gam.overrideAttrs (old: {
      # the Python wrapper hook now passes array entries verbatim.
      makeWrapperArgs = map (arg: lib.removeSuffix "'" (lib.removePrefix "'" arg)) old.makeWrapperArgs;
    }))
    #zoom-us - screensharing doesn't work
  ];
}
