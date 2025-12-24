{
  config,
  lib,
  hostname,
  ...
}:

let
  ports = [
    22 # SSH
    1900 # Rygel
    8000 # Plugins, Ionic
    8096 # Jellyfin
    11434 # Ollama
    53317 # Localsend
  ]
  ++ lib.optionals (hostname == "media") [
    80 # Nginx
    443 # Nginx
  ];
  domains = [
    "home.local"
    "www.home.local"
    "chat.home.local"
    "media.home.local"
  ];
in
{
  networking = {
    hostName = hostname;
    networkmanager.enable = true;

    firewall = {
      allowedTCPPorts = ports;
      allowedUDPPorts = ports;
    }
    // lib.optionalAttrs (hostname == "media") {
      interfaces."${config.services.tailscale.interfaceName}" = {
        allowedTCPPorts = [ 53 ];
        allowedUDPPorts = [ 53 ];
      };
    };

    hosts =
      lib.optionalAttrs (hostname != "media") {
        "192.168.1.78" = domains;
      }
      // lib.optionalAttrs (hostname == "media") {
        "127.0.0.1" = domains;
      };
  };
}
