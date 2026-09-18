_:

{
  # unmerged module from https://github.com/NixOS/nixpkgs/pull/555962
  imports = [ ./module.nix ];
  services.openobserve = {
    enable = true;
    environmentFile = "/var/lib/secrets/openobserve";
    settings = {
      ZO_TELEMETRY = false;
      # allows private ntfy alerts via proxied https address once I update
      # to v1.0.0+
      #ZO_SKIP_SSRF_CHECKS = true;
      # allows private ntfy alerts via `127.0.0.1`
      # remove this in lieu of `ZO_SKIOP_SSRF_CHECKS` onc you update
      ZO_SSRF_ALLOW_LOOPBACK = true;
      ZO_COMPACT_DATA_RETENTION_DAYS = 30;
    };
  };
}
