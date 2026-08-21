_:

{
  services.fetch-rs = {
    enable = true;
    user = "camdenboren";
    onCalendar = "*-*-* *:15:00";
    flakePath = "/home/camdenboren/etc/nixos";
  };
}
