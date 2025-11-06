{ pkgs, hostname, ... }:

let
  jsonFormat = pkgs.formats.json { };
  settings = import ../../../../usr/dot/Mullvad_VPN/settings.nix { inherit hostname; };
in
{
  # Mullvad Settings, may need to remove /etc/mullvad-vpn/settings.json if it's not a fresh install. Requires restart
  environment.etc = {
    "mullvad-vpn/settings.json".source = jsonFormat.generate "settings" settings;
  };
}
