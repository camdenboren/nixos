{
  inputs,
  system,
  ...
}:

{
  nixpkgs.overlays = [
    (
      _final: prev:
      let
        inherit (inputs.firefox-addons.lib.${system}) buildFirefoxXpiAddon;
      in
      {
        firefox-addons = inputs.firefox-addons.packages.${system} // {
          easy-container-shortcuts = prev.callPackage ../../../../drv/easy-container-shortcuts {
            inherit buildFirefoxXpiAddon;
          };
          vimium-new-tab-page = prev.callPackage ../../../../drv/vimium-new-tab-page {
            inherit buildFirefoxXpiAddon;
          };
        };
      }
    )
  ];
}
