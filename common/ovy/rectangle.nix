_:

{
  nixpkgs.overlays = [
    (_final: prev: {
      rectangle = prev.callPackage ../drv/rectangle { };
    })
  ];
}
