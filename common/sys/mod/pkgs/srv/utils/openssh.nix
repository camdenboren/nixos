{ lib, hostname, ... }:

let
  port = toString 22;
  user = "camdenboren";
  needsBuilder = hostname == "media" || hostname == "mainvm";
  sshServer = if needsBuilder then "main" else "media";
  ip = if needsBuilder then "192.168.1.88" else "192.168.1.78";
  authorizedKeys = {
    main = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBrva9LWtBQwBUbc6HxC1DPzPsx32eAP83GS0qNe4M3w camdenboren@media"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMPdyUS3btUZMY5wcmheWwPuHenD8mTYuU402N9L+meO camdenboren@mainvm"
    ];
    media = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIK8GvQ8ynrx87GuJf/9QPwQZLkVrOfb2jEUIU2I8jgsV camdenboren@main"
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDpmm2MT7INoy28MJHDUkl2TFzoXiqcK4ObxeQo1yMgmohyU5VeJwZsSkH+/ZW+r9zG+HpZAccRzaL2vEMscBT/6mkl5S+fU+e7V+wwO9bV3hcfTdyq62Jfk6ejkIPRT3bNQRYWCY7alUyCD2Xpt8JWAfYKhgIDuSxXnEwjbtE4+9Eoxi2/F0wjbfpBHp365FueHiqO1/pNyCYl38BMdp9DV1SGyg4LyDr5gJVFbINiG7NaElCBOXucsBESoZsmbUeFBMMrwKoHj89HXtkQ5fGtGrptF2CyFyKeCYDhySQ8so8vgFQU3AzMDjromiMZReoYv9wGU7EPIRBvZvasCbdW2PI30ty3nyogpCx1sFcIkCRRZNNTtcNlRCMudJTtCxNVDvVrtcvdtwCbr5XAAajxiX1TfDPwxt8TZ3vjWv74JPthO19exLU1H1RB/KJJhU2K13r+YlamIKB9OygZbBx0j2hB4qtI5iZNQeHlnr1EXQBUdtZhWm/NCNoDIdzNzDk= mobile@localhost"
    ];
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

  programs.ssh.extraConfig = lib.optionals (hostname != "macvm") ''
    Host ${sshServer}
      HostName ${ip}
      Port ${port}
      User ${user}
      IdentitiesOnly yes
      IdentityFile ~/.ssh/${sshServer}
  '';

  # This places the clients' public keys on the servers, but you still need to copy
  # each client's private key to it's homedir (from bitwarden) before hitting a
  # `chmod 600 ~/.ssh/another-machine && ssh -i ~/.ssh/another-machine another-machine`
  #
  # See https://wiki.nixos.org/wiki/SSH_public_key_authentication
  # for complete setup steps and explanation
  users.users.camdenboren.openssh.authorizedKeys.keys =
    lib.optionals (hostname == "main") authorizedKeys.main
    ++ lib.optionals (hostname == "media") authorizedKeys.media;
}
