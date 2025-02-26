{ pkgs }:

pkgs.makeDesktopItem rec {
  name = "findVPN";
  desktopName = name;
  exec = name;
  terminal = true;
  icon = "network-vpn";
  comment = "A script for finding an unblocked VPN server to stream YouTube";
  type = "Application";
  categories = [ "Network" ];
}
