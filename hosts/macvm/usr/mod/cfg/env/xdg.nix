{ ... }:

{
  xdg.desktopEntries = {
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
