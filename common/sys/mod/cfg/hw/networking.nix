{
  config,
  lib,
  hostname,
  system,
  ...
}:

let
  isDarwin = lib.hasSuffix "-darwin" system;
  isLinux = !isDarwin;
  ports = [
    22 # SSH
    1900 # Rygel
    8000 # Plugins, Ionic
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
    "dex.home.local"
    "box.home.local"
    "car.home.local"
    "pdf.home.local"
    "sync.home.local"
    "chat.home.local"
    "draw.home.local"
    "notes.home.local"
    "image.home.local"
    "media.home.local"
    "photos.home.local"
    "design.home.local"
    "torrent.home.local"
  ];
in
lib.recursiveUpdate
  # linux-only
  (lib.optionalAttrs isLinux {
    # trust this cert on all devices
    security.pki.certificateFiles = [ ../../../dot/acme/home-local.pem ];

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
  })

  # darwin-only
  # networking.hosts was reverted
  # requires $(sudo -s) + $(mv /etc/hosts /etc/hosts.before-nix-darwin)
  # also need to manually drag and drop home-local.pem to keychain access and `Always Trust`
  (
    lib.optionalAttrs isDarwin {
      environment.etc."hosts" = {
        text = ''
          127.0.0.1       localhost
          255.255.255.255 broadcasthost
          ::1             localhost
          192.168.1.78    ${lib.strings.concatStringsSep " " domains}
        '';
      };
    }
  )
