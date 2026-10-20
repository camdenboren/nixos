_:

let
  baseDomain = "home.local";
in
{
  services.alc-calc = {
    enable = true;
    domain = "alc.${baseDomain}";
    nginx = {
      enable = true;
      virtualHost = {
        forceSSL = true;
        enableACME = true;
      };
    };
  };
}
