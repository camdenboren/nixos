_:

{
  nixpkgs.overlays = [
    (_final: prev: {
      # not in nixpkgs
      actual-cli = prev.callPackage ../drv/actual-cli { };
      drawio = prev.callPackage ../drv/drawio { };
      outline-export = prev.callPackage ../drv/outline-export { };
    })
  ];
}
