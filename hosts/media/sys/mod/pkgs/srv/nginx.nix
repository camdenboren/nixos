{ pkgs, config, ... }:

let
  baseDomain = "home.local";
  baseURL = "http://127.0.0.1";
  macURL = "http://192.168.1.93";
  mainURL = "http://192.168.1.88";
  ports = {
    dex = toString 5556;
    box = toString 7745;
    car = toString 5000;
    log = toString 5080;
    chat = toString 8080;
    sync = toString 8384;
    draw = toString 9040;
    ntfy = toString 2586;
    util = toString 8080;
    omdb = toString 6000;
    gist = toString 6157;
    read = toString 3030;
    notes = toString 3000;
    media = toString 8096;
    image = toString 9090;
    money = toString 4000;
    vault = toString 8222;
    photos = toString 2283;
    design = toString 9001;
    archive = toString 9095;
    homepage = toString 8082;
  };
  domains = {
    www = "www.${baseDomain}";
    dex = "dex.${baseDomain}";
    box = "box.${baseDomain}";
    car = "car.${baseDomain}";
    log = "log.${baseDomain}";
    gist = "gist.${baseDomain}";
    chat = "chat.${baseDomain}";
    sync = "sync.${baseDomain}";
    draw = "draw.${baseDomain}";
    ntfy = "ntfy.${baseDomain}";
    util = "util.${baseDomain}";
    omdb = "omdb.${baseDomain}";
    read = "read.${baseDomain}";
    notes = "notes.${baseDomain}";
    media = "media.${baseDomain}";
    image = "image.${baseDomain}";
    money = "money.${baseDomain}";
    vault = "vault.${baseDomain}";
    photos = "photos.${baseDomain}";
    design = "design.${baseDomain}";
    archive = "archive.${baseDomain}";
  };
  # not included in the existing recommendedProxySettings
  proxyHeaders = ''
    proxy_set_header X-Forwarded-Protocol $scheme;
  '';
  # `SAMEORIGIN` worked, but `frame-ancestors` enables embeds in outline for any
  # static site
  staticHeaders = ''
    add_header Content-Security-Policy "frame-ancestors 'self' https://${domains.notes}" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;
  '';
in
{
  services.nginx = {
    enable = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;
    # the nginx logs indicated the default of 64 is
    # insufficient, presumably because i'm hitting a large
    # number of sites
    appendHttpConfig = ''
      proxy_headers_hash_bucket_size 128;
    '';

    virtualHosts = {
      "${baseDomain}" = {
        default = true;
        forceSSL = true;
        enableACME = true;
        locations = {
          "/" = {
            proxyPass = "${baseURL}:${ports.homepage}";
            extraConfig = proxyHeaders;
          };
        };
      };

      # redirect wwwDomain -> baseDomain
      "${domains.www}" = {
        addSSL = true;
        useACMEHost = baseDomain;
        globalRedirect = baseDomain;
      };

      "${domains.chat}" = {
        forceSSL = true;
        useACMEHost = baseDomain;
        locations = {
          "/" = {
            proxyPass = "${baseURL}:${ports.chat}";
            proxyWebsockets = true;
            extraConfig = proxyHeaders;
          };
        };
      };

      "${domains.media}" = {
        forceSSL = true;
        useACMEHost = baseDomain;
        locations = {
          "/" = {
            proxyPass = "${baseURL}:${ports.media}";
            extraConfig = proxyHeaders + ''
              proxy_buffering off;
            '';
          };

          "/socket" = {
            proxyPass = "${baseURL}:${ports.media}";
            proxyWebsockets = true;
            extraConfig = proxyHeaders;
          };

          # XMLTV guide written by `epg-guide`, so Jellyfin (and other clients)
          # can consume it by URL
          "/epg/" = {
            alias = "/var/lib/epg/";
            extraConfig = ''
              add_header Cache-Control "public, max-age=300" always;
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
            extraConfig = proxyHeaders;
          };
        };
      };

      "${domains.image}" = {
        forceSSL = true;
        useACMEHost = baseDomain;
        locations = {
          "/" = {
            proxyPass = "${mainURL}:${ports.image}";
            extraConfig = proxyHeaders;
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

      "${domains.gist}" = {
        forceSSL = true;
        useACMEHost = baseDomain;
        locations."/" = {
          proxyPass = "${baseURL}:${ports.gist}";
          extraConfig = proxyHeaders + ''
            client_max_body_size 50M;
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

      "${domains.archive}" = {
        forceSSL = true;
        useACMEHost = baseDomain;
        locations = {
          "/" = {
            proxyPass = "${baseURL}:${ports.archive}";
            extraConfig = proxyHeaders;
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
            extraConfig = proxyHeaders + ''
              proxy_redirect off;
              proxy_set_header X-Scheme $scheme;
            '';
          };

          "/ws/notifications" = {
            proxyPass = "${baseURL}:${ports.design}/ws/notifications";
            proxyWebsockets = true;
          };
        };
      };

      "${domains.draw}" = {
        forceSSL = true;
        useACMEHost = baseDomain;
        locations."/" = {
          root = "${pkgs.drawio}";
          index = "index.html";
          tryFiles = "$uri $uri/ /index.html";
        };
        extraConfig = staticHeaders;
      };

      "${domains.omdb}" = {
        forceSSL = true;
        useACMEHost = baseDomain;
        locations = {
          "/" = {
            root = "${pkgs.omdb-lookup}";
            index = "index.html";
            tryFiles = "$uri $uri/ /index.html";
            extraConfig = staticHeaders;
          };
          "/api/" = {
            proxyPass = "${baseURL}:${ports.omdb}/";
            extraConfig = proxyHeaders;
          };
        };
      };

      "${domains.ntfy}" = {
        forceSSL = true;
        useACMEHost = baseDomain;
        locations = {
          "/" = {
            proxyPass = "${baseURL}:${ports.ntfy}";
            proxyWebsockets = true;
            extraConfig = proxyHeaders + ''
              proxy_connect_timeout 3m;
              proxy_send_timeout 3m;
              proxy_read_timeout 3m;
              client_max_body_size 0; # Stream request body to backend
            '';
          };
        };
      };

      "${domains.util}" = {
        forceSSL = true;
        useACMEHost = baseDomain;
        locations = {
          "/" = {
            proxyPass = "${macURL}:${ports.util}";
            extraConfig = proxyHeaders;
            # generate hash w/ the following (you'll be prompted for the password after running)
            # $(nix-shell --packages apacheHttpd --run 'htpasswd -B -c OUTPUT_FILENAME admin')
            basicAuthFile = pkgs.writeText "util-secret" "admin:$2y$05$74lBSfOkE.5UODcfvLDfiuqtiamXf4LG3/XJbdTU848Qnp.Pgg1gW";
          };
        };
      };

      "${domains.box}" = {
        forceSSL = true;
        useACMEHost = baseDomain;
        locations = {
          "/" = {
            proxyPass = "${baseURL}:${ports.box}";
            proxyWebsockets = true;
            extraConfig = proxyHeaders;
          };
        };
      };

      "${domains.log}" = {
        forceSSL = true;
        useACMEHost = baseDomain;
        locations = {
          "/" = {
            proxyPass = "${baseURL}:${ports.log}";
          };
        };
      };

      "${domains.car}" = {
        forceSSL = true;
        useACMEHost = baseDomain;
        locations = {
          "/" = {
            proxyPass = "${baseURL}:${ports.car}";
            proxyWebsockets = true;
            extraConfig = proxyHeaders + ''
              client_max_body_size 50000M;
              proxy_redirect off;
            '';
          };
        };
      };

      "${domains.money}" = {
        forceSSL = true;
        useACMEHost = baseDomain;
        locations = {
          "/" = {
            proxyPass = "${baseURL}:${ports.money}";
            extraConfig = proxyHeaders + ''
              # Prevents header duplication between Upstream and Proxy
              proxy_hide_header Cross-Origin-Embedder-Policy;
              proxy_hide_header Cross-Origin-Opener-Policy;

              # Explicitly set mandatory security headers
              add_header Cross-Origin-Embedder-Policy "require-corp" always;
              add_header Cross-Origin-Opener-Policy "same-origin" always;
              add_header Origin-Agent-Cluster "?1" always;
            '';
          };
        };
      };

      # vaultwarden's module creates the vhost
      "${domains.vault}" = {
        useACMEHost = baseDomain;
        extraConfig = proxyHeaders;
      };

      "${domains.read}" = {
        forceSSL = true;
        useACMEHost = baseDomain;
        locations = {
          "/" = {
            proxyPass = "${baseURL}:${ports.read}";
            extraConfig = proxyHeaders + ''
              # Readest accepts inbox files up to 40 MB through next, which
              # would otw. be truncated by nginx
              client_max_body_size 64M;
            '';
          };

          "/auth/v1/" = {
            proxyPass = "${baseURL}:8010";
            extraConfig = proxyHeaders;
          };

          "/rest/v1/" = {
            proxyPass = "${baseURL}:8010";
            extraConfig = proxyHeaders;
          };

          "/readest-files/" = {
            proxyPass = "${baseURL}:9000";
            extraConfig = proxyHeaders + ''
              proxy_http_version 1.1;
              proxy_set_header Connection "";
              proxy_set_header Accept-Encoding "identity";
              client_max_body_size 0;
              proxy_request_buffering off;
              proxy_buffering off;
            '';
          };
        };
      };
    };
  };

  # exclusively enabled for the minica implementation as
  # public CA renewal fails due to the domain being invalid.
  # see `./minica.nix` for the additional wiring
  security.acme = {
    acceptTerms = true;
    certs."${baseDomain}" = {
      extraDomainNames = builtins.attrValues domains;
      inherit (config.services.nginx) group;
    };
  };
}
