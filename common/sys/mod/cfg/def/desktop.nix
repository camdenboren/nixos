{
  pkgs,
  lib,
  hostname,
  ...
}:

let
  isVM = lib.hasSuffix "vm" hostname;
in
{
  # use x11 remaps in console
  console = {
    useXkbConfig = true;
  };

  # set default term
  xdg.terminal-exec.enable = true;
  programs.nautilus-open-any-terminal = {
    enable = true;
    terminal = "ghostty";
  };

  services = {
    xserver = {
      # Enable the X11 windowing system.
      enable = true;

      # Configure keymap in X11
      xkb = {
        layout = "us";
        variant = "";

        # assign esc -> caps
        options = "caps:escape";
      };
    };

    # Enable the GNOME Desktop Environment.
    desktopManager.gnome.enable = true;

    displayManager = {
      gdm.enable = true;

      # Enable automatic login for the user.
      autoLogin = {
        enable = lib.mkIf isVM true;
        user = lib.mkIf isVM "camdenboren";
      };
    };
  };

  # Workaround for GNOME autologin: https://github.com/NixOS/nixpkgs/issues/103746#issuecomment-945091229
  systemd.services = {
    "getty@tty1".enable = lib.mkIf isVM false;
    "autovt@tty1".enable = lib.mkIf isVM false;
  };

  # Exclude unwanted apps
  environment.gnome.excludePackages = with pkgs; [
    decibels # audio player
    gnome-console
    gnome-contacts
    gnome-music
    gnome-text-editor
    gnome-tour
    gnome-weather
    geary # email client
    simple-scan # document scanner
    showtime # video player
    snapshot # camera app
    yelp # help viewer
  ];
}
