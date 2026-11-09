_:

{
  services.immich = {
    enable = true;
    host = "0.0.0.0";
    mediaLocation = "/mnt/media/Pictures";
    machine-learning.environment.ORT_DISABLE_TELEMETRY = "1";
  };

  users.users.immich = {
    home = "/mnt/media/Pictures";
    createHome = true;
  };
}
