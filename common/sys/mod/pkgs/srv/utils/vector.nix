_:

{
  systemd.services.vector.serviceConfig.EnvironmentFile = "/var/lib/secrets/vector";
  services.vector = {
    enable = true;
    journaldAccess = true;

    settings = {
      sources = {
        journald.type = "journald";
        vector_metrics.type = "internal_metrics";
      };
      sinks = {
        openobserve = {
          type = "http";
          inputs = [ "journald" ];
          uri = "https://log.home.local/api/default/default/_json";
          method = "post";
          compression = "gzip";
          encoding.codec = "json";
          encoding.timestamp_format = "rfc3339";
          healthcheck.enabled = false;
          # requires `VECTOR_DANGEROUSLY_ALLOW_ENV_VAR_INTERPOLATION=true`
          # in the EnvironmentFile
          auth = {
            strategy = "basic";
            user = "\${OPENOBSERVE_USER}";
            password = "\${OPENOBSERVE_PASSWORD}";
          };
        };
      };
    };
  };
}
