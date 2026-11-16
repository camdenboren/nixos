{
  config,
  lib,
  pkgs,
  ...
}:

let
  endpoint = "https://log.home.local/healthz";
in
{
  systemd.services.healthcheck = {
    description = "Check media's OpenObserve health endpoint";
    wants = [ "network-online.target" ];
    after = [ "network-online.target" ];

    serviceConfig = {
      Type = "oneshot";
      # common/sec/healthcheck.yaml supplies NTFY_URL via its
      # `environment` key.
      EnvironmentFile = config.sops.secrets.healthcheck.path;
      DynamicUser = true;
      NoNewPrivileges = true;
      PrivateTmp = true;
      ProtectHome = true;
      ProtectSystem = "strict";
      UMask = "0027";
    };

    script = ''
      set -euo pipefail

      if ! ${pkgs.curl}/bin/curl \
        --fail --silent --show-error \
        --max-time 10 \
        --retry 2 --retry-delay 5 \
        ${lib.escapeShellArg endpoint} >/dev/null
      then
        ${pkgs.curl}/bin/curl \
          --fail --silent --show-error \
          --max-time 10 \
          -d ${lib.escapeShellArg "OpenObserve health check failed on media (${endpoint})"} \
          "$NTFY_URL"
      fi
    '';
  };

  systemd.timers.healthcheck = {
    description = "Run the OpenObserve health check every 5 minutes outside 05:00-05:04 and 06:00-06:04";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      # Skip only the first 5 minutes of 05:00 and 06:00 since the servers are
      # powered on overnight and OpenObserve takes a while to start (covers
      # DST).
      OnCalendar = [
        "*-*-* 00..04,07..23:0/5:00"
        "*-*-* 05,06:5/5:00"
      ];
      AccuracySec = "1s";
    };
  };
}
