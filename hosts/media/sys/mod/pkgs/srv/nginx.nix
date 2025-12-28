{ config, ... }:

let
  ports = {
    homepage = toString 8082;
    chat = toString 8080;
    sync = toString 8384;
    media = toString 8096;
    image = toString 8188;
  };
  baseURL = "http://127.0.0.1";
  mainURL = "http://192.168.1.88";
  baseDomain = "home.local";
  wwwDomain = "www.${baseDomain}";
  chatDomain = "chat.${baseDomain}";
  syncDomain = "sync.${baseDomain}";
  mediaDomain = "media.${baseDomain}";
  imageDomain = "image.${baseDomain}";
  baseHeaders = ''
    proxy_http_version 1.1;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
    proxy_set_header X-Forwarded-Protocol $scheme;
    proxy_set_header X-Forwarded-Host $http_host;
  '';
  websocketHeaders = ''
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection "upgrade";
  '';
in
{
  services.nginx = {
    enable = true;
    proxyTimeout = "300s";
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

      "${chatDomain}" = {
        forceSSL = true;
        useACMEHost = baseDomain;
        locations = {
          "/" = {
            proxyPass = "${baseURL}:${ports.chat}";
            extraConfig = baseHeaders + websocketHeaders;
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
            extraConfig =
              baseHeaders
              + websocketHeaders
              + ''
                proxy_set_header Host $host;
              '';
          };
        };
      };

      "${syncDomain}" = {
        forceSSL = true;
        useACMEHost = baseDomain;
        locations = {
          "/" = {
            proxyPass = "${baseURL}:${ports.sync}";
            extraConfig = baseHeaders;
          };
        };
      };

      "${imageDomain}" = {
        forceSSL = true;
        useACMEHost = baseDomain;
        locations = {
          "/" = {
            proxyPass = "${mainURL}:${ports.image}";
            extraConfig = baseHeaders;
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
