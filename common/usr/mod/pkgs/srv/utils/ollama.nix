{
  pkgs,
  lib,
  hostname,
  ...
}:

{
  services.ollama = {
    enable = true;
    host = "0.0.0.0";
    package = lib.mkIf (hostname == "media") pkgs.ollama-vulkan;
    acceleration = lib.mkIf (hostname == "main") "cuda";
    environmentVariables = {
      OLLAMA_MAX_LOADED_MODELS = "3";
      OLLAMA_NUM_PARALLEL = "4";
      OLLAMA_MAX_QUEUE = "512";
      OLLAMA_CONTEXT_LENGTH = "65536";
      OLLAMA_KEEP_HISTORY = "0";
    };
  };
}
