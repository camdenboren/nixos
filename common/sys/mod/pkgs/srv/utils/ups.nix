{ hostname, ... }:

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
      passwordFile = "/var/lib/secrets/nut";
      upsmon = "primary";
    };

    upsmon.monitor."${name}".user = "upsmon";
  };
}
