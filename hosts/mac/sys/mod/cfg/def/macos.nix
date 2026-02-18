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

        "com.apple.symbolichotkeys" = {
          AppleSymbolicHotKeys = {
            # Schema is:
            #
            # «ACTION» =         {
            #   enabled = «IS_ENABLED»;
            #   value = {
            #     parameters = [
            #       «ASCII»
            #       «KEY_CODE»
            #       «MODIFIERS»
            #     ];
            #     type = "standard";
            #   };
            # };
            #
            # With the vars from the following links:
            # ACTION: https://github.com/NUIKit/CGSInternal/blob/master/CGSHotKeys.h
            # KEY_CODE: https://eastmanreference.com/complete-list-of-applescript-key-codes
            # MODIFIERS: https://gist.github.com/stephancasas/74c4621e2492fb875f0f42778d432973

            # remap kCGSHotKeyDecreaseDisplayBrightness to F1
            "53" = {
              enabled = true;
              value = {
                parameters = [
                  65535 # non-ascii
                  122 # F1
                  8388608 # Fn
                ];
                type = "standard";
              };
            };

            # remap kCGSHotKeyIncreaseDisplayBrightness to F2
            "54" = {
              enabled = true;
              value = {
                parameters = [
                  65535 # non-ascii
                  120 # F2
                  8388608 # Fn
                ];
                type = "standard";
              };
            };

            # disable kCGSHotKeySelectPreviousInputSource on ctrl-spacebar
            # to prevent duplication due to spotlight's remap
            "60" = {
              enabled = false;
              value = {
                parameters = [
                  32 # space
                  49 # spacebar
                  262144 # control
                ];
                type = "standard";
              };
            };

            # remap kCGSHotKeySpotlightSearchField to control-spacebar
            "64" = {
              enabled = true;
              value = {
                parameters = [
                  32 # space
                  49 # spacebar
                  262144 # control
                ];
                type = "standard";
              };
            };

            # remap kCGSHotKeySpotlightWindow to command-option-1
            # idk if this is needed
            "65" = {
              enabled = true;
              value = {
                parameters = [
                  49 # 1
                  18 # 1
                  1572864 # command-option
                ];
                type = "standard";
              };
            };

            # remap kCGSHotKeySpaceLeft to option-command-left
            "79" = {
              enabled = true;
              value = {
                parameters = [
                  65535 # non-ascii
                  123 # left
                  9961472 # option-command-fn
                ];
                type = "standard";
              };
            };

            # remap kCGSHotKeySpaceRight to option-command-right
            "81" = {
              enabled = true;
              value = {
                parameters = [
                  65535 # non-ascii
                  124 # right
                  9961472 # option-command-fn
                ];
                type = "standard";
              };
            };
          };
        };

        NSGlobalDomain = {
          AppleAccentColor = 5;
          AppleHighlightColor = "0.968627 0.831373 1.000000 purple";
          "com.apple.sound.uiaudio.enabled" = 0;
          NSUserKeyEquivalents = {
            Minimize = "^h";
            "Shut Down" = "@~$d";
          };
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
