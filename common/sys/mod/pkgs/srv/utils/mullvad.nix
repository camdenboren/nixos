_:

{
  # Re-add to autostart application in Gnome tweaks when updated to fix out-of-sync error
  services.mullvad-vpn = {
    enable = true;
    gui.enable = true;
  };
}
