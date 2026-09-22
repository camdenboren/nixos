{
  pkgs,
  lib,
  system,
  ...
}:

let
  localURL = "home.local";
  nixSearchURL = "https://search.nixos.org";
  nixos-icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
  homepage = "https://vimium.github.io/new-tab/";
  webAppProfileURI = "/home/camdenboren/.librewolf/webapp";
  jsonFormat = pkgs.formats.json { };
  isLinux = lib.hasSuffix "-linux" system;
  unstable = {
    name = "channel";
    value = "unstable";
  };
  query = {
    name = "query";
    value = "{searchTerms}";
  };
  options = {
    name = "type";
    value = "options";
  };
  packages = {
    name = "type";
    value = "packages";
  };
  nix-darwin = {
    name = "source";
    value = "darwin";
  };
  home-manager = {
    name = "source";
    value = "home_manager";
  };
  mkWebApp =
    {
      name,
      id,
      url,
      icon ? lib.strings.toLower name,
    }:
    pkgs.makeDesktopItem {
      inherit icon;
      name = lib.strings.toLower name;
      desktopName = name;
      exec = ''
        "${pkgs.librewolf}/bin/librewolf" "-taskbar-tab" "${id}" "-new-window" "${url}" "-profile" "${webAppProfileURI}" "-container" "0"
      '';
      type = "Application";
    };
  mkTaskbarEntry =
    {
      name,
      hostname,
      startUrl,
      prefix ? "/",
      id,
    }:
    {
      inherit name startUrl id;
      scopes = [ { inherit hostname prefix; } ];
      userContextId = 0;
      shortcutRelativePath = "${name}.desktop";
    };
  mkTaskbarTabs = { taskbarTabs }: {
    version = 1;
    inherit taskbarTabs;
  };
  mkSettings =
    {
      id ? 0,
      clearCookies,
    }:
    {
      inherit id;
      settings = {
        "browser.startup.homepage" = homepage;
        "browser.toolbars.bookmarks.visibility" = "never";
        "browser.urlbar.suggest.bookmark" = false;
        "browser.urlbar.suggest.history" = false;
        "browser.urlbar.suggest.openpage" = false;
        "browser.urlbar.suggest.topsites" = false;
        "browser.search.separatePrivateDefault" = false;
        "browser.search.suggest.enabled" = false;
        "browser.urlbar.suggest.searches" = false;
        "browser.aboutConfig.showWarning" = false;
        "browser.shell.checkDefaultBrowser" = false;
        "extensions.update.enabled" = false;
        "extensions.update.autoUpdateDefault" = false;
        "privacy.donottrackheader.enabled" = true;
        "privacy.globalprivacycontrol.enabled" = true;
        "privacy.resistFingerprinting" = true;
        "privacy.sanitize.sanitizeOnShutdown" = true;
        "privacy.clearOnShutdown_v2.cache" = true;
        "privacy.clearOnShutdown_v2.cookiesAndStorage" = clearCookies;
        "privacy.clearOnShutdown_v2.historyFormDataAndDownloads" = true;
        "browser.formfill.enable" = false;
        "privacy.userContext.newTabContainerOnLeftClick.enabled" = true;
        "identity.fxaccounts.enabled" = false;
        "places.history.enabled" = false;
        "browser.urlbar.shortcuts.bookmarks" = false;
        "browser.urlbar.shortcuts.history" = false;
        "browser.urlbar.shortcuts.tabs" = false;
        "browser.urlbar.history" = false;
        "browser.ctrlTab.sortByRecentlyUsed" = false;
        "browser.warnOnQuitShortcut" = false;
        "browser.download.useDownloadDir" = false;
        "browser.download.autohideButton" = true;
        "browser.safebrowsing.malware.enabled" = false;
        "browser.safebrowsing.phishing.enabled" = false;
        "browser.safebrowsing.downloads.enabled" = false;
        "media.videocontrols.picture-in-picture.video-toggle.enabled" = false;
        "layout.spellcheckDefault" = 0;
        "browser.sessionstore.resume_from_crash" = false;
        "devtools.responsive.reloadConditions.touchSimulation" = true;
        "devtools.responsive.reloadConditions.userAgent" = true;
        "devtools.responsive.reloadNotification.enabled" = false;
        "browser.tabs.insertAfterCurrent" = true;
        "extensions.autoDisableScopes" = 0;
        "general.autoScroll" = false;
        "middlemouse.paste" = true;
        "clipboard.autocopy" = true;
        "webgl.disabled" = true;
        "security.OCSP.require" = true;
        "browser.contentblocking.category" = "strict";
        "dom.security.https_only_mode" = true;
        "network.lna.skip-domains" = "*.${localURL}";
        "security.enterprise_roots.enabled" = true;
        "browser.newtabpage.activity-stream.asrouter.userprefs.cfr.addons" = false;
        "browser.newtabpage.activity-stream.asrouter.userprefs.cfr.features" = false;
        "browser.newtabpage.activity-stream.feeds.topsites" = false;
        "browser.taskbarTabs.enabled" = true;
        "extensions.formautofill.addresses.enabled" = false;
        "extensions.formautofill.creditCards.enabled" = false;
        "signon.rememberSignons" = false;
        "sidebar.verticalTabs" = true;
        "sidebar.verticalTabs.dragToPinPromo.dismissed" = true;
        "sidebar.revamp" = true;
        "sidebar.main.tools" = [ ];
        "sidebar.visibility" = "always-show";
        "browser.uiCustomization.state" = {
          placements = {
            widget-overflow-fixed-list = [ ];
            unified-extensions-area = [
              "ublock0_raymondhill_net-browser-action"
              "newtaboverride_agenedia_com-browser-action"
              "_d7742d87-e61d-4b78-b8a1-b469842139fa_-browser-action"
              "harper_writewithharper_com-browser-action"
              "7esoorv3_alefvanoon_anonaddy_me-browser-action"
              "addon_darkreader_org-browser-action"
            ];
            nav-bar = [
              "back-button"
              "forward-button"
              "stop-reload-button"
              "urlbar-container"
              "vertical-spacer"
              "downloads-button"
              "unified-extensions-button"
            ];
            TabsToolbar = [ ];
            vertical-tabs = [ "tabbrowser-tabs" ];
            PersonalToolbar = [ "personal-bookmarks" ];
          };
          seen = [
            "harper_writewithharper_com-browser-action"
            "_d7742d87-e61d-4b78-b8a1-b469842139fa_-browser-action"
            "7esoorv3_alefvanoon_anonaddy_me-browser-action"
            "addon_darkreader_org-browser-action"
            "newtaboverride_agenedia_com-browser-action"
            "developer-button"
            "ublock0_raymondhill_net-browser-action"
            "screenshot-button"
          ];
          dirtyAreaCache = [
            "unified-extensions-area"
            "nav-bar"
            "TabsToolbar"
            "vertical-tabs"
            "PersonalToolbar"
          ];
          currentVersion = 23;
          newElementCount = 8;
        };
        "browser.uiCustomization.navBarWhenVerticalTabs" = [
          "unified-extensions-button"
          "urlbar-container"
          "vertical-spacer"
          "forward-button"
          "back-button"
        ];
        "browser.uiCustomization.horizontalTabstrip" = [
          "tabbrowser-tabs"
          "new-tab-button"
        ];
      };

      extensions.packages = with pkgs.firefox-addons; [
        darkreader
        libredirect
        easy-container-shortcuts
        new-tab-override
        vimium
        vimium-new-tab-page
        private-grammar-checker-harper
      ];

      containersForce = true;
      containers = {
        container1 = {
          name = "Personal";
          icon = "fingerprint";
          id = 1;
        };
        container2 = {
          name = "Work";
          icon = "briefcase";
          id = 2;
        };
        container3 = {
          name = "Code";
          icon = "tree";
          id = 3;
        };
        container4 = {
          name = "Banking";
          icon = "dollar";
          id = 4;
        };
        container5 = {
          name = "Tech";
          icon = "circle";
          id = 5;
        };
        container6 = {
          name = "Shopping";
          icon = "cart";
          id = 6;
        };
      };

      search = {
        default = "ddg";
        force = true;
        order = [
          "Nix packages"
          "NixOS options"
          "nix-darwin options"
          "Home Manager options"
        ];

        engines = {
          "Nix packages" = {
            icon = nixos-icon;
            definedAliases = [ "@np" ];
            urls = [
              {
                template = "${nixSearchURL}/packages";
                params = [
                  unstable
                  query
                  packages
                ];
              }
            ];
          };

          "NixOS options" = {
            icon = nixos-icon;
            definedAliases = [ "@no" ];
            urls = [
              {
                template = "${nixSearchURL}/options";
                params = [
                  unstable
                  query
                  options
                ];
              }
            ];
          };

          "nix-darwin options" = {
            icon = nixos-icon;
            definedAliases = [ "@nd" ];
            urls = [
              {
                template = "${nixSearchURL}/options";
                params = [
                  unstable
                  query
                  nix-darwin
                  options
                ];
              }
            ];
          };

          "Home Manager options" = {
            icon = nixos-icon;
            definedAliases = [ "@hm" ];
            urls = [
              {
                template = "${nixSearchURL}/options";
                params = [
                  unstable
                  query
                  home-manager
                  options
                ];
              }
            ];
          };
        };
      };
    };
in
{
  programs.librewolf = {
    enable = true;
    profiles = {
      camdenboren = {
        inherit (mkSettings { clearCookies = true; })
          id
          settings
          extensions
          containersForce
          containers
          search
          ;
      };
      webapp = {
        inherit
          (mkSettings {
            id = 1;
            clearCookies = false;
          })
          id
          settings
          extensions
          containersForce
          containers
          search
          ;
      };
    };
  };

  home.packages = lib.optionals isLinux [
    (mkWebApp {
      name = "Notes";
      id = "14286e74-8231-4b2b-ab16-d2137bfa640f";
      url = "https://notes.home.local/";
    })
    (mkWebApp {
      name = "Duck";
      id = "47d00cad-e4c5-4052-b9bd-287564922433";
      url = "https://duck.ai/";
    })
    (mkWebApp {
      name = "Mailbox";
      id = "4c1cfa47-ec69-4953-af80-3b485080cf79";
      url = "https://app.mailbox.org/appsuite/#pwa=true";
    })
    (mkWebApp {
      name = "Photos";
      id = "e1efc652-60a9-4b16-88ac-1f62961f3a38";
      url = "https://photos.home.local/";
    })
    (mkWebApp {
      name = "Media";
      id = "ff3e78e2-5741-4f08-8404-23d307b46284";
      url = "https://media.home.local/web/index.html#/home";
    })
    (mkWebApp {
      name = "Chat";
      id = "598680e9-2877-49f0-80f4-9d180ef18413";
      url = "https://chat.home.local/";
    })
  ];

  home.file = lib.mkIf isLinux {
    ".librewolf/webapp/taskbartabs/taskbartabs.json" = {
      source = jsonFormat.generate "taskbartabs" (mkTaskbarTabs {
        taskbarTabs = [
          (mkTaskbarEntry {
            name = "Notes";
            hostname = "notes.home.local";
            startUrl = "https://notes.home.local/";
            id = "14286e74-8231-4b2b-ab16-d2137bfa640f";
          })
          (mkTaskbarEntry {
            name = "Duck";
            hostname = "duck.ai";
            startUrl = "https://duck.ai/";
            id = "47d00cad-e4c5-4052-b9bd-287564922433";
          })
          (mkTaskbarEntry {
            name = "Mailbox";
            hostname = "app.mailbox.org";
            startUrl = "https://app.mailbox.org/appsuite/#pwa=true";
            prefix = "/appsuite/";
            id = "4c1cfa47-ec69-4953-af80-3b485080cf79";
          })
          (mkTaskbarEntry {
            name = "Photos";
            hostname = "photos.home.local";
            startUrl = "https://photos.home.local/";
            id = "e1efc652-60a9-4b16-88ac-1f62961f3a38";
          })
          (mkTaskbarEntry {
            name = "Media";
            hostname = "media.home.local";
            startUrl = "https://media.home.local/";
            prefix = "/web/";
            id = "ff3e78e2-5741-4f08-8404-23d307b46284";
          })
          (mkTaskbarEntry {
            name = "Chat";
            hostname = "chat.home.local";
            startUrl = "https://chat.home.local/";
            id = "598680e9-2877-49f0-80f4-9d180ef18413";
          })
        ];
      });
    };
  };
}
