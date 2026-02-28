{ lib, config, ... }:

{
  systemd.services."shutdown" = lib.mkIf (config.specialisation == { }) {
    script = ''
      set -eu
      shutdown
    '';
    serviceConfig = {
      Type = "oneshot";
      User = "root";
    };
    startAt = "*-*-* 23:00:00";
  };
}
