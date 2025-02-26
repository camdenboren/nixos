{
  inputs,
  system,
  ...
}:

{
  nixpkgs.overlays = [
    (
      final: prev:
      let
        buildFirefoxXpiAddon = inputs.firefox-addons.lib.${system}.buildFirefoxXpiAddon;
      in
      {
        firefox-addons = inputs.firefox-addons.packages.${system} // {
          easy-container-shortcuts = (
            prev.callPackage ../../../../drv/easy-container-shortcuts { inherit buildFirefoxXpiAddon; }
          );
        };
      }
    )
  ];
}
