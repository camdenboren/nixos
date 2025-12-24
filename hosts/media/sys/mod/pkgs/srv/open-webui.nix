{ ... }:

{
  services.open-webui = {
    enable = true;
    openFirewall = true;
    environment = {
      OLLAMA_API_BASE_URL = "http://192.168.1.88:11434";
      ANONYMIZED_TELEMETRY = "False";
      DO_NOT_TRACK = "True";
      SCARF_NO_ANALYTICS = "True";
    };
  };
}
