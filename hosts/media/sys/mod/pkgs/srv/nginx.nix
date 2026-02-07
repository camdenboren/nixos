{ pkgs, config, ... }:

let
  baseDomain = "home.local";
  baseURL = "http://127.0.0.1";
  mainURL = "http://192.168.1.88";
  ports = {
    homepage = toString 8082;
    dex = toString 5556;
    box = toString 7745;
    chat = toString 8080;
    sync = toString 8384;
    draw = toString 9040;
    notes = toString 3000;
    media = toString 8096;
    image = toString 8188;
    photos = toString 2283;
    design = toString 9001;
    torrent = toString 9080;
  };
  domains = {
    www = "www.${baseDomain}";
    dex = "dex.${baseDomain}";
    box = "box.${baseDomain}";
    pdf = "pdf.${baseDomain}";
    notes = "notes.${baseDomain}";
    chat = "chat.${baseDomain}";
    sync = "sync.${baseDomain}";
    draw = "draw.${baseDomain}";
    media = "media.${baseDomain}";
    image = "image.${baseDomain}";
    photos = "photos.${baseDomain}";
    design = "design.${baseDomain}";
    torrent = "torrent.${baseDomain}";
  };
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
      "${domains.www}" = {
        locations = {
          "/" = {
            extraConfig = ''
              return 301 $scheme://${baseDomain}$request_uri;
            '';
          };
        };
      };

      "${domains.chat}" = {
        forceSSL = true;
        useACMEHost = baseDomain;
        locations = {
          "/" = {
            proxyPass = "${baseURL}:${ports.chat}";
            extraConfig = baseHeaders + websocketHeaders;
          };
        };
      };

      "${domains.media}" = {
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

      "${domains.sync}" = {
        forceSSL = true;
        useACMEHost = baseDomain;
        locations = {
          "/" = {
            proxyPass = "${baseURL}:${ports.sync}";
            extraConfig = baseHeaders;
          };
        };
      };

      "${domains.image}" = {
        forceSSL = true;
        useACMEHost = baseDomain;
        locations = {
          "/" = {
            proxyPass = "${mainURL}:${ports.image}";
            extraConfig = baseHeaders;
            # generate hash w/ $(nix-shell --packages apacheHttpd --run 'htpasswd -B -c FILENAME admin')
            basicAuthFile = (
              pkgs.writeText "comfyui-secret" "admin:$2y$05$xBrlzmW.FiYGDI34FDStJuhKakzNawP.iiXhQXDlSUrkoUP/6NLda"
            );
          };
        };
      };

      "${domains.notes}" = {
        forceSSL = true;
        useACMEHost = baseDomain;
        locations."/" = {
          proxyPass = "${baseURL}:${ports.notes}";
          proxyWebsockets = true;
          extraConfig = ''
            proxy_set_header X-Scheme $scheme;
          '';
        };
      };

      "${domains.dex}" = {
        forceSSL = true;
        useACMEHost = baseDomain;
        locations."/" = {
          proxyPass = "${baseURL}:${ports.dex}";
          proxyWebsockets = true;
        };
      };

      "${domains.photos}" = {
        forceSSL = true;
        useACMEHost = baseDomain;
        locations."/" = {
          proxyPass = "${baseURL}:${ports.photos}";
          proxyWebsockets = true;
          extraConfig = ''
            client_max_body_size 50000M;
            proxy_read_timeout   600s;
            proxy_send_timeout   600s;
            send_timeout         600s;
          '';
        };
      };

      "${domains.pdf}" = {
        forceSSL = true;
        useACMEHost = baseDomain;
        locations."/" = {
          root = "${pkgs.bentopdf}/dist";
          index = "index.html";
          tryFiles = "$uri $uri/ /index.html";
        };
        extraConfig = ''
          add_header X-Frame-Options "SAMEORIGIN" always;
          add_header X-Content-Type-Options "nosniff" always;
          add_header X-XSS-Protection "1; mode=block" always;
        '';
      };

      "${domains.torrent}" = {
        forceSSL = true;
        useACMEHost = baseDomain;
        locations = {
          "/" = {
            proxyPass = "${baseURL}:${ports.torrent}";
            extraConfig = baseHeaders;
          };
        };
      };

      "${domains.design}" = {
        forceSSL = true;
        useACMEHost = baseDomain;
        extraConfig = ''
          client_max_body_size 31457280;
        '';

        locations = {
          "/" = {
            proxyPass = "${baseURL}:${ports.design}";
            extraConfig = baseHeaders + ''
              proxy_redirect off;
              proxy_set_header X-Scheme $scheme;
            '';
          };

          "/ws/notifications" = {
            proxyPass = "${baseURL}:${ports.design}/ws/notifications";
            extraConfig = websocketHeaders;
          };
        };
      };

      "${domains.draw}" = {
        forceSSL = true;
        useACMEHost = baseDomain;
        locations."/" = {
          root = "${pkgs.drawio}/dist";
          index = "index.html";
          tryFiles = "$uri $uri/ /index.html";
        };
        extraConfig = ''
          add_header X-Frame-Options "SAMEORIGIN" always;
          add_header X-Content-Type-Options "nosniff" always;
          add_header X-XSS-Protection "1; mode=block" always;
        '';
      };

      "${domains.box}" = {
        forceSSL = true;
        useACMEHost = baseDomain;
        locations = {
          "/" = {
            proxyPass = "${baseURL}:${ports.box}";
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
      extraDomainNames = builtins.attrValues domains;
      group = config.services.nginx.group;
    };
  };
}
