{ config, ... }:

let
  domain = "home.local";
  tailnetIP = "100.99.5.32";
in
{
  # prevents connection failure (which requires restarting this srv)
  systemd.services.unbound.after = [
    "tailscaled-autoconnect.service"
  ];

  services.unbound = {
    enable = true;
    resolveLocalQueries = false;

    settings = {
      server = {
        interface = [ "${config.services.tailscale.interfaceName}" ];
        access-control = [ "100.0.0.0/8 allow" ];

        local-zone = [ ''"${domain}." redirect'' ];
        local-data = [ ''"${domain}. IN A ${tailnetIP}"'' ];
        local-data-ptr = [ ''"${tailnetIP} ${domain}"'' ];
      };
    };
  };
}
