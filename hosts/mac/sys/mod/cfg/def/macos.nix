{ ... }:

{
  system = {
    defaults = {
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

        #persistent-apps = [];
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
        ShowDate = 2;
        ShowDayOfWeek = false;
      };
      NSGlobalDomain = {
        AppleInterfaceStyle = "Dark";
        #AppleShowAllExtensions = true;
        #AppleShowAllFiles = true;
        "com.apple.mouse.tapBehavior" = 1;
        "com.apple.trackpad.scaling" = 2.5;
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
      universalaccess = {
        reduceTransparency = true; # requires full disk access for terminal
      };
    };

    # keyboard remappings
    keyboard = {
      enableKeyMapping = true;
      remapCapsLockToEscape = true;
    };
  };
}
