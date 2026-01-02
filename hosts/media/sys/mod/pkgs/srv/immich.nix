{ ... }:

{
  services.immich = {
    enable = true;
    host = "0.0.0.0";
    mediaLocation = "/mnt/media/Pictures";
  };

  users.users.immich = {
    home = "/mnt/media/Pictures";
    createHome = true;
  };
}
