{ lib, hostname, ... }:

let
  isVM = lib.hasSuffix "vm" hostname;
in
{
  xdg.autostart = {
    enable = true;
    entries = [
      ../../../dot/autostart/audioPreventsLock.desktop
    ]
    # hacky fix for the blurred gnome panel improperly defaulting to the left
    # (vertical) monitor's width. not sure why chaining the commands via `&&`
    # w/o the `sh -c` call didn't work, but this should do for now
    ++ lib.optionals (hostname == "main") [
      ../../../dot/autostart/fixPanel.desktop
    ];
  };

  xdg.desktopEntries = lib.mkIf isVM {
    "dev.zed.Zed" = {
      categories = [
        "Utility"
        "TextEditor"
        "Development"
        "IDE"
      ];
      comment = "A high-performance, multiplayer code editor.";
      exec =
        "env "
        + lib.optionalString (hostname == "macvm") "WAYLAND_DISPLAY= "
        + "ZED_ALLOW_EMULATED_GPU=1 zeditor %U";
      icon = "zed";
      name = "Zed";
      type = "Application";
      startupNotify = true;
      settings = {
        Keywords = "zed;";
      };

      mimeType = [
        "text/plain"
        "application/x-zerosize"
        "x-scheme-handler/zed"
      ];

      actions = {
        NewWorkspace = {
          name = "Open a new workspace";
          exec =
            "env "
            + lib.optionalString (hostname == "macvm") "WAYLAND_DISPLAY= "
            + "ZED_ALLOW_EMULATED_GPU=1 zeditor --new %U";
        };
      };
    };

    "com.mitchellh.ghostty" = {
      categories = [
        "System"
        "TerminalEmulator"
      ];
      comment = "A terminal emulator";
      exec = "env LIBGL_ALWAYS_SOFTWARE=1 ghostty";
      icon = "com.mitchellh.ghostty";
      name = "Ghostty";
      type = "Application";
      terminal = false;
      startupNotify = true;
      settings = {
        Keywords = "terminal;tty;pty;";
        StartupWMClass = "com.mitchellh.ghostty";
        X-GNOME-UsesNotifications = "true";
        X-TerminalArgExec = "-e";
        X-TerminalArgTitle = "--title=";
        X-TerminalArgAppId = "--class=";
        X-TerminalArgDir = "--working-directory=";
        X-TerminalArgHold = "--wait-after-command";
      };

      actions = {
        new-window = {
          name = "New Window";
          exec = "env LIBGL_ALWAYS_SOFTWARE=1 ghostty";
        };
      };
    };
  };
}
