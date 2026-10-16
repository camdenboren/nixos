{ pkgs, ... }:

{
  services.actual = {
    enable = true;

    settings = {
      port = 4000;
    };
  };

  environment.systemPackages = [ pkgs.actual-cli ];
}
