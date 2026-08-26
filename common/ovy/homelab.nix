_:

{
  nixpkgs.overlays = [
    (_final: prev: {
      # not in nixpkgs
      drawio = prev.callPackage ../drv/drawio { };
    })
  ];
}
