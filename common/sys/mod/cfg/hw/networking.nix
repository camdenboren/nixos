{ hostname, ... }:

let
  ports = [
    22 # SSH
    8000 # Plugins, Ionic
    1900 # Rygel
    11434 # Ollama
    53317 # Localsend
  ];
in
{
  networking = {
    hostName = hostname;
    networkmanager.enable = true;
    firewall = {
      allowedTCPPorts = ports;
      allowedUDPPorts = ports;
    };
  };
}
