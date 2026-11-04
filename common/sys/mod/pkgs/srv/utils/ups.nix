{ config, hostname, ... }:

let
  name = if hostname == "media" then "smart1500lcd" else "bn1500m2";
  model = if hostname == "media" then "Tripp Lite SMART1500LCD" else "APC Back-UPS Pro (BN1500M2)";
in
{
  power.ups = {
    enable = true;

    ups."${name}" = {
      port = "auto";
      driver = "usbhid-ups";
      description = "${model} with 2x 12V 9Ah lead-acid Batt";
    };

    users.upsmon = {
      passwordFile = config.sops.secrets.nut.path;
      upsmon = "primary";
    };

    upsmon.monitor."${name}".user = "upsmon";
  };

  # fixes race condition per https://github.com/NixOS/nixpkgs/issues/525205
  systemd.services.upsdrv = {
    after = [ "systemd-udev-settle.service" ];
    wants = [ "systemd-udev-settle.service" ];
  };
}
