_:

{
  services.fetch-rs = {
    enable = true;
    user = "camdenboren";
    startCalendarInterval.Minute = 15;
    flakePath = "/Users/camdenboren/etc/nixos";
    secretsFile = "/var/lib/secrets/fetch-rs";
  };
}
