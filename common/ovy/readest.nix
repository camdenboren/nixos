_:

{
  nixpkgs.overlays = [
    (_final: prev: {
      # Replace nixpkgs' Readest with the self-hosted desktop build.
      readest = prev.callPackage ../drv/readest { readest = prev.readest; };
    })
  ];
}
