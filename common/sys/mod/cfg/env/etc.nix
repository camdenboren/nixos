{ ... }:

{
  # Mullvad Settings, may need to remove /etc/mullvad-vpn/settings.json if it's not a fresh install. Requires restart
  environment.etc = {
    "mullvad-vpn/settings.json".source = ../../../../usr/dot/Mullvad_VPN/settings.json;
  };
}
