{
  pkgs,
  lib,
  hostname,
  ...
}:

{
  home.packages =
    with pkgs;
    lib.optionals (hostname == "main") [
      freecad
    ];
}
