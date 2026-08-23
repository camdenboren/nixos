_:

{
  nixpkgs.overlays = [
    (_final: prev: {
      # not in nixpkgs
      drawio = prev.callPackage ../../../../drv/drawio { };
      kiwix-mcp = prev.callPackage ../../../../../../../common/usr/drv/kiwix-mcp { };
    })
  ];
}
