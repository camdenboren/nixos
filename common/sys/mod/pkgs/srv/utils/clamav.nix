{
  lib,
  hostname,
  ...
}:

let
  day = "Sat";
  time = "06:15";
  LogFilterPatterns = "~: Not supported file type$";
in
{
  services.clamav = {
    daemon = {
      enable = true;

      settings = {
        ExcludePath = [
          # common false alarms
          "^/home/camdenboren/[.]local/share/Steam/compatibilitytools[.]d(/|$)"
          "^/home/camdenboren/[.]local/share/Steam/steamapps/common(/|$)"
          "^/home/camdenboren/[.]local/share/Steam/steamapps/compatdata(/|$)"
          "^/home/camdenboren/[.]librewolf/camdenboren/extensions(/|$)"
          "^/home/camdenboren/[.]librewolf/webapp/extensions(/|$)"
          "^/home/camdenboren/[.]wine/drive_c/windows/syswow64(/|$)"
          # unreadable file types
          "^/var/lib/containers/storage/overlay(/|$)"
        ];

        # prevents `LibClamAV Warning: cli_realpath: Invalid arguments.`
        MaxDirectoryRecursion = 128;
      };
    };

    updater.enable = true;
    fangfrisch.enable = true;

    scanner = {
      enable = true;
      interval = "${day} *-*-* ${time}:00";
      scanDirectories = [
        "/home"
        "/root"
        "/etc"
        "/var"
        "/opt"
        "/srv"
        "/tmp"
        "/var/tmp"
        "/boot"
      ]
      # this one takes forever since it's a ~12tb drive being scanned by a
      # ~15yo CPU; might separate into a distinct unit in the future to
      # enable daily scans of "normal" targets, w/ weekly reserved for more
      # time-consuming dirs like this, but that's overkill until I setup
      # alerts
      ++ lib.optionals (hostname == "media") [
        "/mnt/media"
      ];
    };
  };

  systemd.services.clamdscan.serviceConfig = {
    inherit LogFilterPatterns;
  };
}
