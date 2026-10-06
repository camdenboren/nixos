_:

let
  baseDomain = "home.local";
in
{
  services.ntfy-sh = {
    enable = true;
    settings = {
      base-url = "https://ntfy.${baseDomain}";
      behind-proxy = true;
      listen-http = "127.0.0.1:2586";
      # enables timely iOS delivery
      upstream-base-url = "https://ntfy.sh";
    };
  };
}
