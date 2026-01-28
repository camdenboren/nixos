{ pkgs, rice, ... }:

let
  coral = rice == "coral";
  nothin = rice == "nothin";
  baseDomain = "home.local";
  tailnetURL = "100.99.5.32:8082";
  mainURL = "http://192.168.1.88:8188";
  homeURL = "https://${baseDomain}";
  pdfURL = "https://pdf.${baseDomain}/";
  chatURL = "https://chat.${baseDomain}/";
  syncURL = "https://sync.${baseDomain}/";
  notesURL = "https://notes.${baseDomain}/";
  mediaURL = "https://media.${baseDomain}/";
  imageURL = "https://image.${baseDomain}/";
  photosURL = "https://photos.${baseDomain}/";
  designURL = "https://design.${baseDomain}/";
  torrentURL = "https://torrent.${baseDomain}/";
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
    package = package;
    openFirewall = true;
    allowedHosts = "${baseDomain},${tailnetURL}";

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
      base = homeURL;
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
        "AI" = [
          {
            "Chat" = {
              icon = "open-webui";
              href = chatURL;
              siteMonitor = chatURL;
            };
          }
          {
            "Image" = {
              icon = "sh-comfyui";
              # monitor main for status, but link to nginx w/ auth
              href = imageURL;
              siteMonitor = mainURL;
            };
          }
        ];
      }
      {
        Content = [
          {
            "Media" = {
              icon = "jellyfin";
              href = mediaURL;
              siteMonitor = mediaURL;
            };
          }
          {
            "Photos" = {
              icon = "immich";
              href = photosURL;
              siteMonitor = photosURL;
            };
          }
        ];
      }
      {
        Utilities = [
          {
            "Design" = {
              icon = "penpot-light";
              href = designURL;
              siteMonitor = designURL;
            };
          }
          {
            "Notes" = {
              icon = "outline";
              href = notesURL;
              siteMonitor = notesURL;
            };
          }
          {
            "PDF" = {
              icon = "bentopdf";
              href = pdfURL;
              siteMonitor = pdfURL;
            };
          }
          {
            "Sync" = {
              icon = "syncthing";
              href = syncURL;
              siteMonitor = syncURL;
            };
          }
          {
            "Torrent" = {
              icon = "qbittorrent";
              href = torrentURL;
              siteMonitor = torrentURL;
            };
          }
        ];
      }
    ];
  };
}
