{ pkgs, pkgs-stable, ... }:

{
  home.packages =
    with pkgs;
    [
      # Office
      slack
      #zoom-us - screensharing doesn't work
    ]
    ++ (with pkgs-stable; [
      gam
    ]);
}
