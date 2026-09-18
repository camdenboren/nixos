_:

{
  imports = [ ./openobserve.nix ];
  services.openobserve = {
    enable = true;
    environmentFile = "/var/lib/secrets/openobserve";
    settings = {
      ZO_TELEMETRY = false;
      ZO_COMPACT_DATA_RETENTION_DAYS = 30;
    };
  };
}
