{ lib, ... }:

{
  specialisation = {
    travel.configuration = {
      systemd.services."shutdown".script = lib.mkForce ''
        set -eu
        echo "shutdown disabled by 'travel' specialisation, doing nothing..."
      '';
    };
  };
}
