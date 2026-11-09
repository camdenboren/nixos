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
          nova-ash = prev.callPackage ../drv/nova-ash {
            inherit buildFirefoxXpiAddon;
          };
          vimium-new-tab-page = prev.callPackage ../drv/vimium-new-tab-page {
            inherit buildFirefoxXpiAddon;
          };
        };
      }
    )
  ];
}
