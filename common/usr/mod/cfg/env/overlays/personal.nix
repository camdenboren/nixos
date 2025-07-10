{ inputs, system, ... }:

{
  nixpkgs.overlays = [
    (final: prev: {
      alc-calc = inputs.alc-calc.packages.${system}.default;
      chat-script = inputs.chat-script.packages.${system}.default;
    })
  ];
}
