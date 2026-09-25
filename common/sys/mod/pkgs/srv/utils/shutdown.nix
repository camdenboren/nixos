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
    };

    startAt = "*-*-* 02:00:00";
  };
}
