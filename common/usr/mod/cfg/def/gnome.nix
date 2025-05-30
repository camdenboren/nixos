{
  pkgs,
  lib,
  hostname,
  ...
}:

let
  isVM = lib.hasSuffix "vm" hostname;
  hasTrackpad = (hostname == "media" || hostname == "macvm");
in
{
  dconf.settings = {
    "org/gnome/desktop/interface" = {
      gtk-theme = "adw-gtk3";
      icon-theme = "Dracula";
      clock-format = "12h";
      clock-show-seconds = false;
      clock-show-weekday = false;
      clock-show-date = false;
      color-scheme = "prefer-dark";
      text-scaling-factor = if (lib.hasPrefix "main" hostname) then 1.15 else 1.25;
    };
    "org/gnome/desktop/sound" = {
      event-sounds = false;
    };
    "org/gnome/desktop/search-providers" = {
      disabled = [
        "org.gnome.Epiphany.desktop"
        "org.gnome.seahorse.Application.desktop"
        "org.gnome.clocks.desktop"
        "org.gnome.Characters.desktop"
        "org.gnome.Calendar.desktop"
        "org.gnome.Calculator.desktop"
        "org.gnome.Contacts.desktop"
      ];
    };
    "org/gnome/desktop/wm/preferences" = {
      button-layout = "appmenu:close";
      focus-mode = "sloppy";
      num-workspaces = 4;
    };
    "org/gnome/mutter" = {
      dynamic-workspaces = false;
      workspaces-only-on-primary = false;
    };
    "org/gnome/desktop/peripherals/mouse" = {
      natural-scroll = hasTrackpad;
      speed = if hasTrackpad then 0.85 else 1.0;
    };
    "org/gnome/desktop/screensaver" = {
      lock-enabled = false;
    };
    "org/gnome/shell" = {
      favorite-apps =
        [
          "org.gnome.Nautilus.desktop"
          "librewolf.desktop"
          "dev.zed.Zed.desktop"
          "com.mitchellh.ghostty.desktop"
        ]
        ++ lib.optionals (!isVM) [
          "bitwarden.desktop"
          "freetube.desktop"
          "tidal-hifi.desktop"
          "com.github.wwmm.easyeffects.desktop"
        ]
        ++ lib.optionals (hostname == "main") [
          "cockos-reaper.desktop"
        ]
        ++ lib.optionals (hostname == "media") [
          "vlc.desktop"
        ]
        ++ lib.optionals (!isVM) [
          "steam.desktop"
        ];
      enabled-extensions =
        [
          "gnome-one-window-wonderland@jqno.nl"
          "blur-my-shell@aunetx"
          "just-perfection-desktop@just-perfection"
          "focus-changer@heartmire"
        ]
        ++ lib.optionals (hostname == "media") [
          "auto-move-windows@gnome-shell-extensions.gcampax.github.com"
        ];
    };
    "org/gnome/shell/extensions/blur-my-shell" = {
      hacks-level = 2;
      sigma = 0;
    };
    "org/gnome/shell/extensions/blur-my-shell/applications" = {
      blur = true;
      customize = false;
      dynamic-opacity = false;
      opacity = 230;
      whitelist = [
        "dev.zed.Zed"
        "com.mitchellh.ghostty"
      ];
    };
    "org/gnome/shell/extensions/blur-my-shell/appfolder" = {
      blur = false;
    };
    "org/gnome/shell/extensions/blur-my-shell/lockscreen" = {
      blur = false;
    };
    # Readjust displays if not working on multi-monitor
    "org/gnome/shell/extensions/blur-my-shell/overview" = {
      blur = true;
      customize = true;
      sigma = 30;
      style-components = 3;
    };
    "org/gnome/shell/extensions/blur-my-shell/panel" = {
      blur = true;
      override-background-dynamically = true;
    };
    "org/gnome/shell/extensions/blur-my-shell/screenshot" = {
      blur = false;
    };
    "org/gnome/shell/extensions/blur-my-shell/window-list" = {
      blur = false;
    };
    "org/gnome/shell/extensions/one-window-wonderland" = {
      ignore-list = lib.mkIf (hostname == "main") "REAPER";
      gap-size = 0;
    };
    "org/gnome/shell/extensions/just-perfection" = {
      # visibility
      accessibility-menu = false;
      dash-separator = false;
      world-clock = false;
      weather = false;
      events-button = false;
      workspace-popup = false;
      workspace = false;
      window-preview-caption = false;

      # icons
      window-picker-icon = false;
      power-icon = false;

      # customize
      startup-status = 0;
      panel-button-padding-size = 1;
      panel-indicator-padding-size = 1;
    };
    "org/gnome/shell/extensions/auto-move-windows" = {
      application-list = [
        "com.github.wwmm.easyeffects.desktop:4"
      ];
    };
    "org/gnome/epiphany" = {
      start-in-incognito-mode = true;
      restore-session-policy = "crashed";
      homepage-url = "about:newtab";
    };
    "org/gnome/epiphany/web" = {
      remember-passwords = false;
    };
    "org/gnome/nautilus/preferences" = {
      show-delete-permanently = true;
    };
    "org/gnome/settings-daemon/plugins/power" = {
      power-button-action = "interactive";
      sleep-inactive-ac-type = "nothing";
    };
    "org/gnome/desktop/session" = {
      idle-delay = lib.hm.gvariant.mkUint32 0;
    };
  };

  # gtk styling
  gtk = {
    enable = true;
    theme.name = "adw-gtk3";
    iconTheme.name = "Dracula";
  };

  # qt styling
  qt = {
    enable = true;
    platformTheme.name = "gtk";
    style.package = pkgs.adwaita-qt; # can use qt6 when vlc is ported
    style.name = "adwaita-dark";
  };
}
