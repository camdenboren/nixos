{ pkgs, hostname }:

let
  name = if hostname == "media" then "smart1500lcd" else "bn1500m2";
in
pkgs.writeShellScriptBin "upsMetrics" ''
  UPS="${name}@localhost"

  get_value() {
    ${pkgs.nut}/bin/upsc "$UPS" 2>/dev/null |
      ${pkgs.gawk}/bin/awk -F': ' -v key="$1" '$1 == key { print $2; exit }'
  }

  input_voltage="$(get_value input.voltage)"
  battery_voltage="$(get_value battery.voltage)"
  battery_charge="$(get_value battery.charge)"

  # Emit one valid JSON object per line.
  printf '{"event":"ups_metrics","ups":"%s","input_voltage":%s,"battery_voltage":%s,"battery_charge":%s}\n' \
    "$UPS" \
    "''${input_voltage:-null}" \
    "''${battery_voltage:-null}" \
    "''${battery_charge:-null}"
''
