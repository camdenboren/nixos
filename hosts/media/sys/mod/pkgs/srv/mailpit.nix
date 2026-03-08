{ ... }:

{
  services.mailpit = {
    instances = {
      "home.local" = {
        smtp = "127.0.0.1:1025";
        max = 500;
        listen = "127.0.0.1:8025";
        database = "mailpit.db";
      };
    };
  };
}
