{ pkgs, ... }:

let
  mac = "68:6C:E6:38:49:F3";
  python = pkgs.python3.withPackages (ps: [ ps.dbus-next ]);
in
{
  systemd.user.services = {
    bluetooth-steam = {
      Unit = {
        Description = "Launch Steam when the Bluetooth device connects";
        After = [ "graphical-session.target" ];
        PartOf = [ "graphical-session.target" ];
      };
      Service = {
        ExecStart = "${python}/bin/python ${./listener.py} ${mac} ${pkgs.systemd}/bin/systemctl --user --no-block start bluetooth-steam-launch.service";
        Restart = "always";
        RestartSec = 5;
      };
      Install.WantedBy = [ "graphical-session.target" ];
    };

    bluetooth-steam-launch = {
      Unit = {
        Description = "Steam launched by a Bluetooth connection";
        PartOf = [ "graphical-session.target" ];
        Requisite = [ "graphical-session.target" ];
        After = [ "graphical-session.target" ];
      };
      Service = {
        Type = "exec";
        ExecStart = "${pkgs.steam}/bin/steam";
      };
    };
  };
}
