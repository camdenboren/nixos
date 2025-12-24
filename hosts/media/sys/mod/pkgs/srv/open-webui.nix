{ ... }:

{
  services.open-webui = {
    enable = true;
    openFirewall = true;
    environment = {
      ENABLE_WEBSOCKET_SUPPORT = "True";
      OLLAMA_API_BASE_URL = "http://192.168.1.88:11434";
      ANONYMIZED_TELEMETRY = "False";
      DO_NOT_TRACK = "True";
      SCARF_NO_ANALYTICS = "True";
    };
  };
}
