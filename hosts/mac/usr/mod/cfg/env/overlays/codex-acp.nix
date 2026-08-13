_:

{
  nixpkgs.overlays = [
    (_final: prev: {
      # nixpkgs is outdated
      codex-acp = prev.callPackage ../../../../drv/codex-acp { };
    })
  ];
}
