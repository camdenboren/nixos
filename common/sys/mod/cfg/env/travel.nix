{ ... }:

{
  specialisation = {
    travel.configuration = {
      systemd.services."shutdown".script = ''
        set -eu
        echo "shutdown disabled by `travel` specialisation, doing nothing..."
      '';
    };
  };
}
