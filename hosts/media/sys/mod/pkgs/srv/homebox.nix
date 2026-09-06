_:

{
  services.homebox = {
    enable = true;
    database.createLocally = true;
    secrets.HBOX_AUTH_API_KEY_PEPPER = "/var/lib/secrets/homebox";
  };
}
