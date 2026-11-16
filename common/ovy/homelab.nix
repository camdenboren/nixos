_:

{
  nixpkgs.overlays = [
    (_final: prev: {
      # not in nixpkgs
      actual-cli = prev.callPackage ../drv/actual-cli { };
      drawio = prev.callPackage ../drv/drawio { };
      omdb-lookup = prev.callPackage ../drv/omdb-lookup { };
      opengist = prev.callPackage ../drv/opengist { };
      outline-export = prev.callPackage ../drv/outline-export { };
      workerd = prev.callPackage ../drv/workerd { };
      container-images = prev.callPackage ../drv/container-images { };
    })
  ];
}
