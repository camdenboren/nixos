{
  config,
  pkgs,
  lib,
  system,
  hostname,
  ...
}:

let
  cfg = config.rice;
  coral = cfg == "coral";
  nothin = cfg == "nothin";
  jsonFormat = pkgs.formats.json { };
  red-theme = import ../../../dot/zed/red.nix { inherit lib system; };
  rose-theme = import ../../../dot/zed/rose.nix;
  isLinux = lib.hasSuffix "-linux" system;
  isMain = lib.hasPrefix "main" hostname;
  zed-variant = if isLinux then "" else " Transparent";

  clr = {
    bg =
      if coral then
        "002b36"
      else if nothin then
        "232136"
      else
        "390000";
    fg = "f8f8f8";

    accent =
      if coral then
        "2190a4"
      else if nothin then
        "9141ac"
      else
        "e62d42";
    accent-bg =
      if coral then
        "247c90"
      else if nothin then
        "7d4698"
      else
        "be2f47";

    cursor = {
      color =
        if coral then
          "278ad1"
        else if nothin then
          "9bced6"
        else
          "970000";
    };

    highlight = {
      bg =
        if coral then
          "2380bd"
        else if nothin then
          "44415a"
        else
          "750000";
      fg = "f8f8f8";
    };

    prompt =
      if coral then
        "1;32"
      else if nothin then
        "1;35"
      else
        "1;33";
    mtx =
      if coral then
        "green"
      else if nothin then
        "magenta"
      else
        "yellow";

    terminal = {
      a-black = "#000000";
      b-red = "#cd3131";
      c-green = "#0dbc79";
      d-yellow = "#e5e510";
      e-blue = "#2472c8";
      f-magenta = "#bc3fbc";
      g-cyan = "#11a8cd";
      h-white = "#e5e5e5";
      i-bright-black = "#666666";
      j-bright-red = "#f14c4c";
      k-bright-green = "#23d18b";
      l-bright-yellow = "#f5f543";
      m-bright-blue = "#3b8eea";
      n-bright-magenta = "#d670d6";
      o-bright-cyan = "#29b8db";
      p-bright-white = "#e5e5e5";
    };
  };

  fonts = {
    mono = "JetBrainsMono Nerd Font";
    serif = "Adwaita Sans";
  };
in
{
  imports = lib.optionals isLinux [ ../env/overlays/icons.nix ];

  options = {
    rice = lib.mkOption {
      default = "skyline";
      type = lib.types.str;
      description = ''
        Rice to use for the user. One of "coral", "nothin", "skyline"

        Sets:
        - Wallpaper, accents, and icons on Linux
        - LibreWolf container colors
        - Bash, Ghostty, Zed colors, fonts

        Default:
        - "skyline"

        Example:
        - rice = "coral";
      '';
    };
  };

  config =
    lib.recursiveUpdate
      # all platforms
      {
        programs.bash = {
          shellAliases.matrix = "${pkgs.cmatrix}/bin/cmatrix -C ${clr.mtx}";
          bashrcExtra = ''
            export PS1="\n\[\033[${clr.prompt}m\][\[\e]0;\u@\h: \w\a\]\u@\h:\w]\$\[\033[0m\] "
          '';
        };

        programs.ghostty = {
          # non-theme settings are in ghostty.nix
          settings = {
            background-opacity = if isLinux then 1.0 else 0.85;
            bold-is-bright = true;
            font-family = fonts.mono;
            font-size =
              if isMain then
                11
              else if isLinux then
                10
              else
                15;
            macos-titlebar-proxy-icon = "hidden"; # mac-only
            theme = "custom";
            title = "\" \"";
            shell-integration-features = "no-cursor";
            window-theme = "ghostty"; # linux-only
            window-title-font-family = fonts.serif;
          };

          themes = {
            custom = {
              background = clr.bg;
              foreground = clr.fg;
              cursor-color = clr.cursor.color;
              cursor-style = "block";
              selection-background = clr.highlight.bg;
              selection-foreground = clr.highlight.fg;

              # prepend 'i=' for each color to conform to iterm2 schema
              palette = lib.lists.imap0 (i: x: toString i + "=" + x) (lib.attrValues clr.terminal);
            };
          };
        };

        programs.zed-editor.userSettings = {
          theme = {
            mode = "system";
            dark =
              if coral then
                "Zed Legacy: Solarized Dark"
              else if nothin then
                "Zed Legacy: Rosé Pine Moon" + zed-variant
              else
                "Red";
            light = "One Light";
          };

          ui_font_family = fonts.serif;
          ui_font_size = if isLinux then 18 else 17;
          buffer_font_family = fonts.mono;
          buffer_font_size = if isLinux then 17 else 16;
          agent_font_size = if isLinux then 18 else 17;
        };

        home.file = {
          ".config/zed/themes/red.json" = {
            source = jsonFormat.generate "red-theme" red-theme;
          };
          ".config/zed/themes/rose.json" = {
            source = jsonFormat.generate "rose-theme" rose-theme;
          };
          ".config/gtk-3.0/gtk.css" = {
            text = ''
              @define-color accent_color #${clr.accent};
              @define-color accent_bg_color #${clr.accent-bg};
            '';
          };
          ".config/gtk-4.0/gtk.css" = {
            text = ''
              @define-color accent_color #${clr.accent};
              @define-color accent_bg_color #${clr.accent-bg};
            '';
          };
        };

        # darwin support is coming soon
        programs.librewolf.profiles.camdenboren = {
          containers = {
            container1.color =
              if coral then
                "blue"
              else if nothin then
                "purple"
              else
                "red";
            container2.color =
              if coral then
                "turquoise"
              else if nothin then
                "blue"
              else
                "orange";
            container3.color =
              if coral then
                "green"
              else if nothin then
                "turquoise"
              else
                "yellow";
            container4.color =
              if coral then
                "yellow"
              else if nothin then
                "green"
              else
                "green";
            container5.color =
              if coral then
                "orange"
              else if nothin then
                "yellow"
              else
                "turquoise";
            container6.color =
              if coral then
                "red"
              else if nothin then
                "red"
              else
                "purple";
          };

          settings = {
            "font.name.serif.x-western" = fonts.serif;
            "font.name.sans-serif.x-western" = fonts.serif;
            "font.name.monospace.x-western" = fonts.mono;
          };
        };
      }

      # linux-only
      (
        lib.optionalAttrs isLinux {
          # nix-darwin is needed to set macOS wallpaper
          # see hosts/mac/sys/mod/cfg/env/activation.nix
          dconf.settings =
            let
              uri = "file://" + "/home/camdenboren/etc/nixos/common/usr/rice/wallpapers/${cfg}.jpg";
            in
            {
              "org/gnome/desktop/background" = {
                picture-uri = uri;
                picture-uri-dark = uri;
              };

              "org/gnome/desktop/interface" = {
                accent-color =
                  if coral then
                    "teal"
                  else if nothin then
                    "purple"
                  else
                    "red";
              };
            };
        }
      );
}
