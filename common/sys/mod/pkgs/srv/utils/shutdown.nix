{ ... }:

{
  systemd.services."shutdown" = {
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
