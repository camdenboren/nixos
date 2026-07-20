_:

{
  # hacky fix for the blurred gnome panel improperly defaulting to the left (vertical) monitor's width
  # not sure why chaining the commands via `&&` w/o the `sh -c` call didn't work, but this should do for now
  xdg.autostart = {
    enable = true;
    entries = [ ../../../dot/fixPanel/fixPanel.desktop ];
  };
}
