{ ... }:

let
  domain = "people.home.local";
in
{
  services.monica = {
    enable = true;
    hostname = domain;
    appKeyFile = "/var/lib/secrets/monica";

    config = {
      MAIL_MAILER = "smtp";
      MAIL_HOST = "localhost";
      MAIL_PORT = 1025;
      MAIL_FROM_ADDRESS = "no-reply@xxx.com";
      MAIL_FROM_NAME = "Monica";
    };

    nginx = {
      forceSSL = true;
      enableACME = true;
    };
  };
}
