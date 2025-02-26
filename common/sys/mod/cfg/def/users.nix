{
  lib,
  hostname,
  ...
}:

{
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.camdenboren = {
    isNormalUser = true;
    description = "Camden Boren";
    extraGroups =
      [
        "networkmanager"
        "wheel"
      ]
      ++ lib.optionals (hostname == "main") [
        "audio"
      ];
  };
}
