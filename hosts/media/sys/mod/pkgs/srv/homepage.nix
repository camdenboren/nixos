{ pkgs, rice, ... }:

let
  coral = rice == "coral";
  nothin = rice == "nothin";
  baseDomain = "home.local";
  tailnetAddress = "100.99.5.32:8082";
  URLs = {
    main = "http://192.168.1.88:8188";
    home = "https://${baseDomain}";
    pdf = "https://pdf.${baseDomain}/";
    box = "https://box.${baseDomain}/";
    car = "https://car.${baseDomain}/";
    chat = "https://chat.${baseDomain}/";
    sync = "https://sync.${baseDomain}/";
    draw = "https://draw.${baseDomain}/";
    notes = "https://notes.${baseDomain}/";
    media = "https://media.${baseDomain}/";
    image = "https://image.${baseDomain}/";
    money = "https://money.${baseDomain}/";
    photos = "https://photos.${baseDomain}/";
    design = "https://design.${baseDomain}/";
    people = "https://people.${baseDomain}/";
    torrent = "https://torrent.${baseDomain}/";
  };
  backgrounds = {
    coral = ../../../../../../common/usr/rice/wallpapers/coral.jpg;
    nothin = ../../../../../../common/usr/rice/wallpapers/nothin.jpg;
    skyline = ../../../../../../common/usr/rice/wallpapers/skyline.jpg;
  };
  homepageImagesURI = "$out/share/homepage/public/images";
  package = pkgs.homepage-dashboard.overrideAttrs (oldAttrs: {
    postInstall = oldAttrs.postInstall or "" + ''
      mkdir -p $out/share/homepage/public/images
      ln -s ${backgrounds.coral} ${homepageImagesURI}/coral.jpg
      ln -s ${backgrounds.nothin} ${homepageImagesURI}/nothin.jpg
      ln -s ${backgrounds.skyline} ${homepageImagesURI}/skyline.jpg
    '';
  });
in
{
  services.homepage-dashboard = {
    enable = true;
    inherit package;
    openFirewall = true;
    allowedHosts = "${baseDomain},${tailnetAddress}";

    settings = {
      background = {
        image = "/images/${rice}.jpg";
        blur = "md";
      };
      theme = "dark";
      color =
        if coral then
          "teal"
        else if nothin then
          "purple"
        else
          "red";
      base = URLs.home;
      statusStyle = "dot";
      layout = {
        AI = {
          style = "row";
          columns = 2;
        };
        Content = {
          style = "row";
          columns = 2;
        };
        Graphics = {
          style = "row";
          columns = 2;
        };
        Tracking = {
          style = "row";
          columns = 2;
        };
        Utilities = {
          style = "row";
          columns = 2;
        };
      };
    };

    widgets = [
      {
        resources = {
          cpu = true;
          disk = [
            "/"
            "/mnt/media"
          ];
          memory = true;
        };
      }
      {
        datetime = {
          format = {
            timeStyle = "short";
            timeZone = "America/Chicago";
          };
        };
      }
    ];

    services = [
      {
        AI = [
          {
            Chat = {
              icon = "open-webui";
              href = URLs.chat;
              siteMonitor = URLs.chat;
            };
          }
          {
            Image = {
              icon = "sh-comfyui";
              # monitor main for status, but link to nginx w/ auth
              href = URLs.image;
              siteMonitor = URLs.main;
            };
          }
        ];
      }
      {
        Content = [
          {
            Media = {
              icon = "jellyfin";
              href = URLs.media;
              siteMonitor = URLs.media;
            };
          }
          {
            Photos = {
              icon = "immich";
              href = URLs.photos;
              siteMonitor = URLs.photos;
            };
          }
        ];
      }
      {
        Graphics = [
          {
            Design = {
              icon = "penpot-light";
              href = URLs.design;
              siteMonitor = URLs.design;
            };
          }
          {
            Draw = {
              icon = "draw-io";
              href = URLs.draw;
              siteMonitor = URLs.draw;
            };
          }
        ];
      }
      {
        Tracking = [
          {
            Box = {
              icon = "homebox";
              href = URLs.box;
              siteMonitor = URLs.box;
            };
          }
          {
            Car = {
              icon = "lubelogger";
              href = URLs.car;
              siteMonitor = URLs.car;
            };
          }
          {
            Money = {
              icon = "actual-budget";
              href = URLs.money;
              siteMonitor = URLs.money;
            };
          }
          {
            People = {
              icon = "monica";
              href = URLs.people;
              siteMonitor = URLs.people;
            };
          }
        ];
      }
      {
        Utilities = [
          {
            Notes = {
              icon = "outline";
              href = URLs.notes;
              siteMonitor = URLs.notes;
            };
          }
          {
            PDF = {
              icon = "bentopdf";
              href = URLs.pdf;
              siteMonitor = URLs.pdf;
            };
          }
          {
            Sync = {
              icon = "syncthing";
              href = URLs.sync;
              siteMonitor = URLs.sync;
            };
          }
          {
            Torrent = {
              icon = "qbittorrent";
              href = URLs.torrent;
              siteMonitor = URLs.torrent;
            };
          }
        ];
      }
    ];
  };
}
