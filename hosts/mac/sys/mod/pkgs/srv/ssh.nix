_:

{
  programs.ssh = {
    extraConfig = ''
      Host edu-nation.org
        HostName edu-nation.org
        User edunati1
        UseKeychain yes
        AddKeysToAgent yes
        IdentityFile ~/.ssh/edu-nation.org
        IdentitiesOnly yes
    '';
    knownHosts = {
      "edu-nation.org".publicKey =
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILleP1OVhqR8llrBYmXZ9me8wSbiI+sMDMpz5vG6Bcrd";
    };
  };
}
