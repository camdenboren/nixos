{ config, ... }:

let
  ports = {
    homepage = toString 8082;
    media = toString 8096;
  };
  baseURL = "http://127.0.0.1";
  baseDomain = "home.local";
  wwwDomain = "www.${baseDomain}";
  mediaDomain = "media.${baseDomain}";
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
    recommendedTlsSettings = true;

    virtualHosts = {
      # redirect http -> https
      "_" = {
        extraConfig = ''
          return 301 https://$host$request_uri;
        '';
      };

      "${baseDomain}" = {
        forceSSL = true;
        enableACME = true;
        locations = {
          "/" = {
            proxyPass = "${baseURL}:${ports.homepage}";
            extraConfig = baseHeaders + ''
              proxy_set_header Host $host;
            '';
          };
        };
      };

      # redirect wwwDomain -> baseDomain
      "${wwwDomain}" = {
        locations = {
          "/" = {
            extraConfig = ''
              return 301 $scheme://${baseDomain}$request_uri;
            '';
          };
        };
      };

      "${mediaDomain}" = {
        forceSSL = true;
        useACMEHost = baseDomain;
        locations = {
          "/" = {
            proxyPass = "${baseURL}:${ports.media}";
            extraConfig = baseHeaders + ''
              proxy_buffering off;
            '';
          };

          "/socket" = {
            proxyPass = "${baseURL}:${ports.media}";
            extraConfig = baseHeaders + ''
              proxy_set_header Upgrade $http_upgrade;
              proxy_set_header Connection "upgrade";
              proxy_set_header Host $host;
            '';
          };
        };
      };
    };

  };

  security.acme = {
    acceptTerms = true;
    defaults.email = "9UtEfABpSSrV3g.code@mailbox.org";
    certs."${baseDomain}" = {
      extraDomainNames = [ mediaDomain ];
      group = config.services.nginx.group;
    };
  };
}
