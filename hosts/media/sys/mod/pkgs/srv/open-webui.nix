{ pkgs-stable, ... }:

let
  scheme = "http";
  port = toString 11434;
  domain = "chat.home.local";
  URLs = {
    main = "${scheme}://192.168.1.88:${port}";
    windows = "${scheme}://192.168.1.65:${port}";
  };
in
{
  services.open-webui = {
    enable = true;
    package = pkgs-stable.open-webui;
    environment = {
      DO_NOT_TRACK = "True";
      SCARF_NO_ANALYTICS = "True";
      ANONYMIZED_TELEMETRY = "False";
      ENABLE_WEBSOCKET_SUPPORT = "True";
      CORS_ALLOW_ORIGIN = "https://${domain}";
      OLLAMA_BASE_URLS = "${URLs.main};${URLs.windows}";
    };
  };
}
