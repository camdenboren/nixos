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
      age
      sops
      ssh-to-age
      localsend
    ]
    ++ lib.optionals (lib.hasSuffix "-linux" system) [
      qpwgraph
      nvtopPackages.full
      hfsprogs
    ];
}
