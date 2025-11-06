{ hostname, ... }:

{
  preferredLocale = "system";
  autoConnect = (hostname == "main");
  enableSystemNotifications = true;
  monochromaticIcon = true;
  startMinimized = true;
  unpinnedWindow = true;
  browsedForSplitTunnelingApplications = [ ];
  changelogDisplayedForVersion = "2025.7";
  animateMap = true;
}
