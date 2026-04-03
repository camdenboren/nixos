{ ... }:

{
  services.invidious = {
    enable = true;
    port = 9050;
    domain = "youtube.home.local";

    settings = {
      db.user = "invidious";
    };
  };
}
