{ inputs, system, ... }:

{
  nixpkgs.overlays = [
    (_final: _prev: {
      alc-calc = inputs.alc-calc.packages.${system}.default;
      yt-x = inputs.yt-x.packages.${system}.default;
    })
  ];
}
