{ lib, hostname, ... }:

let
  port = toString 22;
  user = "camdenboren";
  ip = {
    main = "192.168.1.88";
    media = "192.168.1.78";
  };
  authorizedKeys = {
    main = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBrva9LWtBQwBUbc6HxC1DPzPsx32eAP83GS0qNe4M3w camdenboren@media";
    media = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIK8GvQ8ynrx87GuJf/9QPwQZLkVrOfb2jEUIU2I8jgsV camdenboren@main";
  };
in
{
  services.openssh = {
    enable = true;
    ports = [ 22 ];
    # require public key authentication for better security
    settings.PasswordAuthentication = false;
    settings.KbdInteractiveAuthentication = false;
  };

  programs.ssh.extraConfig = ''
    Host main
      HostName ${ip.main}
      Port ${port}
      User ${user}

    Host media
      HostName ${ip.media}
      Port ${port}
      User ${user}
  '';

  # See https://wiki.nixos.org/wiki/SSH_public_key_authentication
  # for complete setup steps and explanation
  users.users.camdenboren.openssh.authorizedKeys.keys =
    lib.optionals (hostname == "main") [
      authorizedKeys.main
    ]
    ++ lib.optionals (hostname == "media") [
      authorizedKeys.media
    ];
}
