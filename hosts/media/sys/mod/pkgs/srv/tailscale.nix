{
  config,
  lib,
  ...
}:

let
  # Mullvad split-tunnel marks.
  mullvadEscapeMark = "0x6d6f6c65";
  mullvadCtMark = "0x00000f41";
  tailnetRange4 = "100.64.0.0/10";
  tailnetRange6 = "fd7a:115c:a1e0::/48";

  escapeChains =
    v4:
    let
      range = if v4 then tailnetRange4 else tailnetRange6;
      addr = if v4 then "ip" else "ip6";
    in
    ''
      chain output {
        type route hook output priority mangle; policy accept;
        ${lib.optionalString v4 ''${addr} daddr 100.64.0.0/24 return comment "mullvad infra"''}
        ${addr} daddr ${range} ct mark set ${mullvadCtMark} meta mark set ${mullvadEscapeMark}
        meta mark & 0xff0000 == 0x80000 counter ct mark set ${mullvadCtMark} meta mark set ${mullvadEscapeMark}
      }

      chain prerouting {
        type filter hook prerouting priority mangle + 10; policy accept;
        iifname "${config.services.tailscale.interfaceName}" ct mark set ${mullvadCtMark}
      }
    '';
in
{
  services.tailscale = {
    enable = true;
    # comment this out on first run
    authKeyFile = config.sops.secrets.tailscale.path;
    extraDaemonFlags = [ "--no-logs-no-support" ];

    # Avoid Mullvad mark and DNS conflicts.
    extraUpFlags = [
      "--netfilter-mode=off"
      "--accept-dns=false"
    ];
    extraSetFlags = config.services.tailscale.extraUpFlags;
  };

  # tell ts to use nftables
  systemd.services.tailscaled.environment.TS_DEBUG_FIREWALL_MODE = "nftables";

  networking = {
    firewall.checkReversePath = "loose";
    nftables = {
      enable = true;
      # Preserve VPN-managed tables.
      flushRuleset = false;
      tables.tailscale-mullvad-v4 = {
        family = "ip";
        content = escapeChains true;
      };
      tables.tailscale-mullvad-v6 = {
        family = "ip6";
        content = escapeChains false;
      };
    };
  };
}
