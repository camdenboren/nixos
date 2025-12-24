{ pkgs, ... }:

{
  services.comfyui = {
    enable = true;
    openFirewall = true;
    acceleration = "cuda";
    models = with pkgs.nixified-ai.models; [
      stable-diffusion-v1-5
      dreamshaper-8-pruned-checkpoints
    ];
  };
}
