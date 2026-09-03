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
      # enables timely iOS delivery
      upstream-base-url = "https://ntfy.sh";
    };
  };
}
