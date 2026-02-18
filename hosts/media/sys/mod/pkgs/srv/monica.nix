{ ... }:

let
  domain = "people.home.local";
in
{
  services.monica = {
    enable = true;
    hostname = domain;
    appKeyFile = "/var/lib/secrets/monica";

    nginx = {
      forceSSL = true;
      enableACME = true;
    };
  };
}
