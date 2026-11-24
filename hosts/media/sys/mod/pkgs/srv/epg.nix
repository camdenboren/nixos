{
  lib,
  pkgs,
  ...
}:

# Regenerates an XMLTV guide for Jellyfin's iptv-org playlists; nginx serves it
# at media.home.local/epg/guide.xml (a local path also works).
let
  playlists = [
    "https://iptv-org.github.io/iptv/sources/us_tubi.m3u"
    "https://iptv-org.github.io/iptv/sources/us_pluto.m3u"
    "https://iptv-org.github.io/iptv/cities/usdal.m3u"
  ];
in
{
  users.users.epg = {
    isSystemUser = true;
    group = "epg";
  };
  users.groups.epg = { };

  systemd.services.epg-guide = {
    description = "Generate an XMLTV guide for Jellyfin's iptv-org playlists";
    wants = [ "network-online.target" ];
    after = [ "network-online.target" ];

    serviceConfig = {
      Type = "oneshot";
      User = "epg";
      Group = "epg";
      ExecStart = "${pkgs.epg}/bin/epg-refresh";
      Environment = [
        "GUIDE_DIR=/var/lib/epg"
        "DATA_DIR=/var/lib/epg/data"
        "PLAYLISTS=${lib.concatStringsSep "," playlists}"
        "SITE_PRIORITY=pluto.tv,plex.tv,xumo.tv,i.mjh.nz"
        "DAYS=2"
        "MAX_CONNECTIONS=4"
      ];
      TimeoutStartSec = "2h";
      StateDirectory = "epg";
      # Jellyfin (another user) reads the guide
      StateDirectoryMode = "0755";
      UMask = "0022";
      NoNewPrivileges = true;
      PrivateTmp = true;
      ProtectHome = true;
      ProtectSystem = "strict";
      RestrictAddressFamilies = [
        "AF_INET"
        "AF_INET6"
        "AF_UNIX"
      ];
    };
  };

  systemd.timers.epg-guide = {
    description = "Refresh the Jellyfin XMLTV guide daily";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "*-*-* 11:00:00";
    };
  };
}
