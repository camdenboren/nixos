{ inputs, system, ... }:

{
  nixpkgs.overlays = [
    (final: prev: {
      alc-calc = inputs.alc-calc.packages.${system}.default;
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
