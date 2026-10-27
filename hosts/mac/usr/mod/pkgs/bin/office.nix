{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # Office
    gam
    #zoom-us - screensharing doesn't work
  ];
}
