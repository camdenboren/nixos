{ ... }:

let
  baseDomain = "home.local";
  homeURL = "https://${baseDomain}";
  chatURL = "https://chat.${baseDomain}/";
  syncURL = "https://sync.${baseDomain}/";
  mediaURL = "https://media.${baseDomain}/";
  imageURL = "https://image.${baseDomain}/";
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
        "Content & Utilities" = {
          style = "row";
          columns = 2;
        };
        AI = {
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
        "Content & Utilities" = [
          {
            "Media" = {
              icon = "jellyfin";
              href = mediaURL;
              siteMonitor = mediaURL;
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
    ];
  };
}
