{ ... }:

{
  services.homepage-dashboard = {
    enable = true;
    openFirewall = true;
    allowedHosts = "home.local";

    settings = {
      background = {
        image = "https://wallpapercave.com/wp/wp8975927.jpg";
        blur = "md";
      };
      theme = "dark";
      color = "teal";
      base = "http://home.local";
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
              href = "http://media.home.local/";
              siteMonitor = "http://media.home.local/";
            };
          }
        ];
      }
    ];
  };
}
