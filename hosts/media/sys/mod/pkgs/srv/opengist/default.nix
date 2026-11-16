{ ... }:

{
  imports = [ ./module.nix ];

  services.opengist = {
    enable = true;
    externalUrl = "https://gist.home.local";
    settings."log-level" = "info";
  };
}
