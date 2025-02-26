{
  pkgs,
  lib,
  system,
  ...
}:

{
  home.packages =
    with pkgs;
    [
      # Utilities
      cachix
      localsend
    ]
    ++ lib.optionals (lib.hasSuffix "-linux" system) [
      qpwgraph
      nvtopPackages.full
      hfsprogs
    ];
}
