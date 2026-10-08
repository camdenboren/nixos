_:

{
  systemd.services."shutdown" = {
    script = ''
      set -eu
      shutdown
    '';

    serviceConfig = {
      Type = "oneshot";
      User = "root";
      NoNewPrivileges = true;
      PrivateTmp = true;
      ProtectHome = true;
      ProtectSystem = "strict";
    };

    startAt = "*-*-* 02:00:00";
  };
}
