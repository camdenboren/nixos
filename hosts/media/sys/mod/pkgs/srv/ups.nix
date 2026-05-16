_:

let
  name = "smart1500lcd";
in
{
  power.ups = {
    enable = true;

    ups."${name}" = {
      port = "auto";
      driver = "usbhid-ups";
      description = "Tripp Lite SMART1500LCD with 2x 12V 9Ah lead-acid Batt";
    };

    users.upsmon = {
      passwordFile = "/var/lib/secrets/nut";
      upsmon = "primary";
    };

    upsmon.monitor."${name}".user = "upsmon";
  };
}
