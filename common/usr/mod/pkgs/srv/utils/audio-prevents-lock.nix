{ pkgs, ... }:

let
  script = pkgs.writeShellScriptBin "audio-prevents-lock" ''
    # from https://askubuntu.com/questions/1564792/is-there-any-way-to-keep-pc-from-suspending-while-playing-audio
    exec 2>/dev/null
    while : ; do
      ${pkgs.coreutils}/bin/sleep 1
      if ${pkgs.pulseaudio}/bin/pactl list sinks short | ${pkgs.gnugrep}/bin/grep -q RUNNING$ ; then
        # We're using sleep 999999 because waitpid $$ doesn't work for @Stygian
        # If you want to log out then back in without rebooting, ensure that
        # only one instance of the sleep process and this script run
        ${pkgs.gnome-session}/bin/gnome-session-inhibit ${pkgs.coreutils}/bin/sleep 999999 &
        pid=$!
        while ${pkgs.pulseaudio}/bin/pactl list sinks short | ${pkgs.gnugrep}/bin/grep -q RUNNING$ ; do
          ${pkgs.coreutils}/bin/sleep 1
        done
        kill -9 "$pid"
      fi
    done
  '';
in
{
  # Inhibits GNOME idle while audio is playing.
  systemd.user.services.audio-prevents-lock = {
    Unit = {
      Description = "Prevent GNOME idle while audio is playing";
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
    };
    Service = {
      ExecStart = "${script}/bin/audio-prevents-lock";
      Restart = "always";
      RestartSec = 5;
      NoNewPrivileges = true;
      PrivateTmp = true;
      ProtectSystem = true;
      UMask = "0027";
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };
}
