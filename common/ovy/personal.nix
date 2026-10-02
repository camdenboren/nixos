{ inputs, system, ... }:

{
  nixpkgs.overlays = [
    (_final: _prev: {
      alc-calc = inputs.alc-calc.packages.${system}.default;
      alc-calc-web = inputs.alc-calc.packages.${system}.web;
      yt-x = inputs.yt-x.packages.${system}.default;
    })
  ];
}
