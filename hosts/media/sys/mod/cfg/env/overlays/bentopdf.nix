{ ... }:

{
  nixpkgs.overlays = [
    (final: prev: {
      # not in nixpkgs
      bentopdf = prev.callPackage ../../../../drv/bentopdf { };
    })
  ];
}
