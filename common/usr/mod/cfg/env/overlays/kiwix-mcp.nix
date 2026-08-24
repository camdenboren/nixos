_:

{
  nixpkgs.overlays = [
    (_final: prev: {
      kiwix-mcp = prev.callPackage ../../../../drv/kiwix-mcp { selfSignedCerts = true; };
    })
  ];
}
