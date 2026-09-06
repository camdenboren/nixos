_:

let
  baseDomain = "home.local";
in
{
  services.bentopdf = {
    enable = true;
    domain = "pdf.${baseDomain}";
    nginx = {
      enable = true;
      virtualHost = {
        forceSSL = true;
        enableACME = true;
      };
    };
  };
}
