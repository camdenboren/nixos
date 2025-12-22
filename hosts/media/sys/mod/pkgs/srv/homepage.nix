{ ... }:

let
  baseDomain = "home.local";
  homeURL = "https://${baseDomain}";
  mediaURL = "https://media.${baseDomain}/";
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
        Services = {
          style = "row";
          columns = 1;
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
        "Services" = [
          {
            "Media" = {
              icon = "jellyfin";
              href = mediaURL;
              siteMonitor = mediaURL;
            };
          }
        ];
      }
    ];
  };
}
