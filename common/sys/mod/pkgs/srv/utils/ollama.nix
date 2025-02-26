{
  lib,
  hostname,
  ...
}:

{
  services.ollama = {
    enable = true;
    acceleration = lib.mkIf (hostname == "main") "cuda";
    host = "0.0.0.0";
  };
}
