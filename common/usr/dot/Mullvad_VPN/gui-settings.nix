{ hostname, ... }:

{
  preferredLocale = "system";
  autoConnect = hostname == "main";
  enableSystemNotifications = true;
  monochromaticIcon = true;
  startMinimized = true;
  unpinnedWindow = true;
  browsedForSplitTunnelingApplications = [ ];
  changelogDisplayedForVersion = "2026.5";
  updateDismissedForVersion = "";
  animateMap = true;
}
