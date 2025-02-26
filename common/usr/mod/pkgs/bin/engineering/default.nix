{
  pkgs,
  lib,
  hostname,
  ...
}:

{
  home.packages =
    with pkgs;
    [
      #apio
      #look into Verilog-HDL ext. for codium by mshr-h
      #openFPGALoader
      kicad-small
    ]
    ++ lib.optionals (hostname == "main") [
      freecad
    ];
}
