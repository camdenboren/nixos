{ inputs, system, ... }:

{
  nixpkgs.overlays = [
    (final: prev: {
      alc-calc = inputs.alc-calc.packages.${system}.default;
      yt-x = inputs.yt-x.packages.${system}.default;
    })
  ];
}
