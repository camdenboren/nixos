{ inputs, pkgs, ... }:

let
  ports = {
    nginx = toString 90;
    nginxTls = toString 453;
  };
  baseDomain = "192.168.1.78";
in
{
  systemd.services.appflowy-cloud = {
    script = ''
      NGINX_PORT=${ports.nginx} \
      NGINX_TLS_PORT=${ports.nginxTls} \
      FQDN=${baseDomain}:${ports.nginx} \
      ${pkgs.docker-compose}/bin/docker-compose \
        -f ${inputs.appflowy-cloud}/docker-compose.yml \
        --env-file ${inputs.appflowy-cloud}/deploy.env \
        up 
    '';
    preStop = ''
      ${pkgs.docker-compose}/bin/docker-compose \
        -f ${inputs.appflowy-cloud}/docker-compose.yml \
        down 
    '';
    wantedBy = [ "multi-user.target" ];
  };
}
