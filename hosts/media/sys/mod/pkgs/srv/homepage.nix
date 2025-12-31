{ ... }:

let
  baseDomain = "home.local";
  homeURL = "https://${baseDomain}";
  chatURL = "https://chat.${baseDomain}/";
  syncURL = "https://sync.${baseDomain}/";
  notesURL = "https://notes.${baseDomain}/";
  mediaURL = "https://media.${baseDomain}/";
  imageURL = "https://image.${baseDomain}/";
  photosURL = "https://photos.${baseDomain}/";
in
{
  services.homepage-dashboard = {
    enable = true;
    openFirewall = true;
    allowedHosts = baseDomain;

    settings = {
      background = {
        image = "https://wallpapercave.com/wp/wp8975927.jpg";
        blur = "md";
      };
      theme = "dark";
      color = "teal";
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
              href = imageURL;
              siteMonitor = imageURL;
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
            "Notes" = {
              icon = "outline";
              href = notesURL;
              siteMonitor = notesURL;
            };
          }
          {
            "Sync" = {
              icon = "syncthing";
              href = syncURL;
              siteMonitor = syncURL;
            };
          }
        ];
      }
    ];
  };
}
