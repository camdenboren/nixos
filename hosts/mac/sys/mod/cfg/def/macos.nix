{ pkgs, ... }:

{
  power.sleep = {
    computer = "never";
    display = "never";
  };

  system = {
    defaults = {
      CustomUserPreferences = {
        "com.apple.screensaver" = {
          idleTime = 0;
        };
        NSGlobalDomain = {
          AppleAccentColor = 5;
          AppleHighlightColor = "0.968627 0.831373 1.000000 purple";
          "com.apple.sound.uiaudio.enabled" = 0;
        };
      };

      dock = {
        tilesize = 54;
        magnification = false;

        orientation = "right";
        mineffect = "genie";
        minimize-to-application = false;

        autohide = true;
        launchanim = true;
        show-process-indicators = true;
        show-recents = false;

        appswitcher-all-displays = true;
        enable-spring-load-actions-on-all-items = true;
        mouse-over-hilite-stack = false;
        mru-spaces = false;

        # set hot corners, where 1 = disabled and 2 = mission control
        wvous-bl-corner = 1;
        wvous-br-corner = 1;
        wvous-tl-corner = 2;
        wvous-tr-corner = 1;

        persistent-apps = [
          "${pkgs.librewolf}/Applications/LibreWolf.app"
          "${pkgs.zed-editor}/Applications/Zed.app"
          "${pkgs.ghostty-bin}/Applications/Ghostty.app"
          "${pkgs.bitwarden-desktop}/Applications/Bitwarden.app"
          "/Applications/FreeTube.app"
          "${pkgs.vlc-bin}/Applications/VLC.app"
          "${pkgs.slack}/Applications/Slack.app"
          "/Applications/ClickUp.app"
          "/Applications/zoom.us.app"
          "${pkgs.utm}/Applications/UTM.app"
        ];
      };

      finder = {
        AppleShowAllExtensions = true;
        AppleShowAllFiles = true;
        FXDefaultSearchScope = "SCcf";
        FXPreferredViewStyle = "NIsv";
        _FXShowPosixPathInTitle = true;
        QuitMenuItem = true;
      };

      LaunchServices.LSQuarantine = false;

      loginwindow = {
        GuestEnabled = false;
        SHOWFULLNAME = false;
      };

      menuExtraClock = {
        ShowAMPM = false;
        ShowDate = 2;
        ShowDayOfWeek = false;
      };

      NSGlobalDomain = {
        AppleInterfaceStyle = "Dark";
        AppleIconAppearanceTheme = "TintedDark";
        AppleShowScrollBars = "WhenScrolling";
        "com.apple.mouse.tapBehavior" = 1;
        "com.apple.trackpad.scaling" = 2.5;
        "com.apple.swipescrolldirection" = false;
        "com.apple.trackpad.enableSecondaryClick" = true;
        NSDisableAutomaticTermination = false;
        NSScrollAnimationEnabled = true;
      };

      screencapture.location = "~/Downloads/Images";

      spaces.spans-displays = true;

      trackpad = {
        FirstClickThreshold = 1;
        SecondClickThreshold = 1;
        Clicking = true;
      };

      universalaccess.reduceTransparency = true; # requires full disk access for terminal
    };

    # keyboard remappings
    keyboard = {
      enableKeyMapping = true;
      remapCapsLockToEscape = true;
    };

    startup.chime = false;
  };
}
