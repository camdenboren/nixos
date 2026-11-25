{ config, pkgs, ... }:

{
  services.vaultwarden = {
    enable = true;
    package = pkgs.vaultwarden-postgresql;
    dbBackend = "postgresql";

    # `nginx.nix` adds the shared ACME cert
    configureNginx = true;
    configurePostgres = true;
    domain = "vault.home.local";

    environmentFile = config.sops.secrets.vaultwarden.path;

    config = {
      SIGNUPS_ALLOWED = false;
      _ENABLE_SMTP = false;
      ROCKET_ADDRESS = "127.0.0.1";
      ROCKET_PORT = 8222;
      ROCKET_LOG = "critical";
    };
  };
}
