{ pkgs, hostname, ... }:

let
  baseURL = "https://log.home.local/api/default";
  upsMetrics = import ../../../../../usr/scr/upsMetrics.nix { inherit pkgs hostname; };
  # requires `VECTOR_DANGEROUSLY_ALLOW_ENV_VAR_INTERPOLATION=true`
  # in the EnvironmentFile
  auth = {
    strategy = "basic";
    user = "\${OPENOBSERVE_USER}";
    password = "\${OPENOBSERVE_PASSWORD}";
  };
in
{
  systemd.services.vector.serviceConfig.EnvironmentFile = "/var/lib/secrets/vector";
  services.vector = {
    enable = true;
    journaldAccess = true;

    settings = {
      sources = {
        journald.type = "journald";
        vector_metrics.type = "internal_metrics";
        host_metrics.type = "host_metrics";
        ups_metrics_json = {
          type = "exec";
          command = [ "${upsMetrics}/bin/upsMetrics" ];
          mode = "scheduled";
          scheduled.exec_interval_secs = 15;
          include_stderr = false;
          decoding.codec = "json";
        };
      };

      transforms.ups_metrics = {
        type = "log_to_metric";
        inputs = [ "ups_metrics_json" ];
        metrics =
          map
            (metric: {
              type = "gauge";
              inherit (metric) field name;
              tags = {
                host = hostname;
                ups = "{{ups}}";
              };
            })
            [
              {
                field = "input_voltage";
                name = "ups_input_voltage_volts";
              }
              {
                field = "battery_voltage";
                name = "ups_battery_voltage_volts";
              }
              {
                field = "battery_charge";
                name = "ups_battery_charge_percent";
              }
            ];
      };

      sinks = {
        openobserve = {
          inherit auth;
          type = "http";
          inputs = [ "journald" ];
          uri = "${baseURL}/default/_json";
          method = "post";
          compression = "gzip";
          encoding.codec = "json";
          encoding.timestamp_format = "rfc3339";
          healthcheck.enabled = false;
        };
        openobserve_metrics = {
          inherit auth;
          type = "prometheus_remote_write";
          inputs = [
            "vector_metrics"
            "host_metrics"
            "ups_metrics"
          ];
          endpoint = "${baseURL}/prometheus/api/v1/write";
          healthcheck.enabled = false;
        };
      };
    };
  };
}
