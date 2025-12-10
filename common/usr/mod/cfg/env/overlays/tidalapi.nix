{ ... }:

{
  nixpkgs.overlays = [
    (final: prev: {
      python313Packages = prev.python313Packages.override {
        overrides = (
          python-final: python-prev: {
            tidalapi = prev.callPackage ../../../../drv/tidalapi { };
          }
        );
      };
    })
  ];
}
