_:

{
  nixpkgs.overlays = [
    (_final: prev: {
      # not in nixpkgs
      bentopdf = prev.callPackage ../../../../drv/bentopdf { };
      drawio = prev.callPackage ../../../../drv/drawio { };
      monochrome = prev.callPackage ../../../../drv/monochrome { };
    })
  ];
}
