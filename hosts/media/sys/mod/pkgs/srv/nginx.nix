{ ... }:

let
  baseHeaders = ''
    proxy_http_version 1.1;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
    proxy_set_header X-Forwarded-Protocol $scheme;
    proxy_set_header X-Forwarded-Host $http_host;
  '';
in
{
  services.nginx = {
    enable = true;
    recommendedProxySettings = true;

    virtualHosts."home.local" = {
      locations = {
        "/" = {
          proxyPass = "http://127.0.0.1:8082";
          extraConfig = baseHeaders + ''
            proxy_set_header Host $host;
          '';
        };
      };
    };

    virtualHosts."www.home.local" = {
      locations = {
        "/" = {
          extraConfig = ''
            return 301 $scheme://home.local$request_uri;
          '';
        };
      };
    };

    virtualHosts."media.home.local" = {
      locations = {
        "/" = {
          proxyPass = "http://127.0.0.1:8096";
          extraConfig = baseHeaders + ''
            proxy_buffering off;
          '';
        };

        "/socket" = {
          proxyPass = "http://127.0.0.1:8096";
          extraConfig = baseHeaders + ''
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection "upgrade";
            proxy_set_header Host $host;
          '';
        };
      };
    };
  };
}
