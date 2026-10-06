{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.security.acme;

  mkReloadScript =
    cert: data:
    let
      certDir = "/var/lib/acme/${cert}";
    in
    pkgs.writeShellScript "minica-reload-${cert}" ''
      set -euo pipefail

      ${pkgs.coreutils}/bin/touch ${lib.escapeShellArg "${certDir}/reload-pending"}
      ${pkgs.systemd}/bin/systemctl try-reload-or-restart ${lib.escapeShellArgs data.reloadServices}
      ${pkgs.coreutils}/bin/rm -f ${lib.escapeShellArg "${certDir}/reload-pending"}
    '';

  mkReloadTrigger =
    cert:
    let
      certDir = "/var/lib/acme/${cert}";
    in
    pkgs.writeShellScript "minica-trigger-reload-${cert}" ''
      set -euo pipefail

      ${pkgs.coreutils}/bin/touch ${lib.escapeShellArg "${certDir}/reload-pending"}
      ${pkgs.systemd}/bin/systemctl --no-block start ${lib.escapeShellArg "minica-reload-${cert}.service"}
    '';

  mkReloadService = cert: data: {
    description = "Reload services after renewing minica certificate for ${cert}";
    after = [ "acme-${cert}.service" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = toString (mkReloadScript cert data);
    };
  };

  mkRenewService =
    cert: data:
    let
      certDir = "/var/lib/acme/${cert}";
      renewBeforeDays = if data.validMinDays == null then 30 else data.validMinDays;
      renewBeforeSeconds = renewBeforeDays * 24 * 60 * 60;
    in
    {
      description = "Renew minica certificate for ${cert}";

      path = [
        pkgs.coreutils
        pkgs.openssl
        pkgs.systemd
      ];

      serviceConfig.Type = "oneshot";

      script = ''
        set -euo pipefail

        if ! [ -s ${lib.escapeShellArg "${certDir}/cert.pem"} ] \
          || ! openssl x509 -checkend ${toString renewBeforeSeconds} \
            -noout -in ${lib.escapeShellArg "${certDir}/cert.pem"};
        then
          rm -f ${lib.escapeShellArg "${certDir}/acme-success"}
          systemctl restart ${lib.escapeShellArg "acme-${cert}.service"}
        fi

        ${lib.optionalString (data.reloadServices != [ ]) ''
          if [ -e ${lib.escapeShellArg "${certDir}/reload-pending"} ]; then
            systemctl start ${lib.escapeShellArg "minica-reload-${cert}.service"}
          fi
        ''}
      '';
    };
in
{
  config = lib.mkIf (cfg.certs != { }) {
    # Keep the upstream module's minica bootstrap implementation, but disable
    # every service and timer that invokes lego.
    systemd.services =
      lib.mapAttrs' (
        cert: data: lib.nameValuePair "minica-renew-${cert}" (mkRenewService cert data)
      ) cfg.certs
      // lib.mapAttrs' (
        cert: data: lib.nameValuePair "minica-reload-${cert}" (mkReloadService cert data)
      ) (lib.filterAttrs (_: data: data.reloadServices != [ ]) cfg.certs)
      // lib.mapAttrs' (
        cert: data:
        lib.nameValuePair "acme-${cert}" {
          serviceConfig.ExecStartPost = lib.mkIf (data.reloadServices != [ ]) "-+${mkReloadTrigger cert}";
        }
      ) cfg.certs
      // lib.mapAttrs' (
        cert: _: lib.nameValuePair "acme-order-renew-${cert}" { enable = false; }
      ) cfg.certs;

    systemd.timers =
      lib.mapAttrs' (
        cert: data:
        lib.nameValuePair "minica-renew-${cert}" {
          description = "Renew minica certificate for ${cert}";
          wantedBy = [ "timers.target" ];
          timerConfig = {
            OnCalendar = data.renewInterval;
            RandomizedDelaySec = data.renewJitter;
            Persistent = true;
            Unit = "minica-renew-${cert}.service";
          };
        }
      ) cfg.certs
      // lib.mapAttrs' (cert: _: lib.nameValuePair "acme-renew-${cert}" { enable = false; }) cfg.certs;
  };
}
