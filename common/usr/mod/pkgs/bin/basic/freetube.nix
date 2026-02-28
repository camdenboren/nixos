{
  pkgs,
  lib,
  system,
  hostname,
  ...
}:

let
  isDarwin = lib.hasSuffix "-darwin" system;
in
{
  programs.freetube = {
    enable = true;
    package = if isDarwin then null else pkgs.freetube;

    # doesn't put settings.db in correct location on mac, so it's copied in replaceConfigs.nix
    settings = {
      bounds = {
        x = if isDarwin then 136 else 925;
        y = if isDarwin then 254 else 346;
        width = if isDarwin then 2288 else 723;
        height = if isDarwin then 1262 else 802;
        maximized = true;
        fullScreen = false;
      };
      checkForUpdates = false;
      checkForBlogPosts = false;
      hideHeaderLogo = true;
      mainColor = if (hostname == "media") then "Teal" else "Red";
      secColor = if (hostname == "media") then "CatppuccinFrappeTeal" else "Red";
      autoplayVideos = true;
      defaultQuality = "1080";
      fetchSubscriptionsAutomatically = false;
      saveWatchedProgress = false;
      rememberHistory = false;
      useSponsorBlock = true;
      sponsorBlockShowSkippedToast = false;
      sponsorBlockSelfPromo = {
        color = "Yellow";
        skip = "autoSkip";
      };
      sponsorBlockInteraction = {
        color = "Green";
        skip = "doNothing";
      };
      uiScale = 110;
      defaultViewingMode = "theatre";
      displayVideoPlayButton = false;
      externalPlayer = "mpv";
      rememberSearchHistory = false;
      baseTheme = "black";
      hideLabelsSideBar = true;
      hideActiveSubscriptions = true;
      enableSubtitlesByDefault = true;
    }
    // lib.optionalAttrs isDarwin {
      externalPlayerExecutable = "/Users/camdenboren/.nix-profile/bin/mpv";
    };
  };
}
