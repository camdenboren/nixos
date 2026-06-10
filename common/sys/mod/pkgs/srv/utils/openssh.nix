_:

let
  port = toString 22;
  user = "camdenboren";
  ip = {
    main = "192.168.1.88";
    media = "192.168.1.78";
  };
in
{
  services.openssh = {
    enable = true;
    ports = [ 22 ];
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
}
