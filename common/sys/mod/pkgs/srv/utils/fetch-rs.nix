{ config, ... }:

{
  services.fetch-rs = {
    enable = true;
    user = "camdenboren";
    onCalendar = "*-*-* *:15:00";
    flakePath = "/home/camdenboren/etc/nixos";
    secretsFile = config.sops.secrets.fetch-rs.path;
  };
}
