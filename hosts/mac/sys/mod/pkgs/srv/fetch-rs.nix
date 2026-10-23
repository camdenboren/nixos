{ config, ... }:

{
  services.fetch-rs = {
    enable = true;
    user = "camdenboren";
    startCalendarInterval.Minute = 15;
    flakePath = "/Users/camdenboren/etc/nixos";
    secretsFile = config.sops.secrets.fetch-rs.path;
  };
}
