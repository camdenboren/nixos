{
  pkgs,
  lib,
  hostname,
  ...
}:

{
  services.ollama = {
    enable = true;
    package = lib.mkIf (hostname == "media") pkgs.ollama-vulkan;
    acceleration = lib.mkIf (hostname == "main") "cuda";
    host = "0.0.0.0";
  };
}
