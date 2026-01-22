{
  pkgs,
  hostname,
  ...
}:

let
  nixos-icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
  homepage =
    if hostname == "mac" then
      "moz-extension://1b0f4899-1e5e-4c97-8e53-bfc8ede4fc68/pages/blank.html"
    else if hostname == "macvm" then
      "moz-extension://95b3696c-386b-4e5a-ab96-556425d9a46f/pages/blank.html"
    else if hostname == "main" then
      "moz-extension://04cc90c6-c702-4205-9ce0-b81be2036116/pages/blank.html"
    else if hostname == "mainvm" then
      "moz-extension://40d2adc1-a6c5-4500-9c07-c8ec2725d78e/pages/blank.html"
    else if hostname == "media" then
      "moz-extension://b50b3a02-d24d-4ebe-bdce-c29d3978adbd/pages/blank.html"
    else
      "";
  query = {
    name = "query";
    value = "{searchTerms}";
  };
in
{
  imports = [
    ../../../cfg/env/overlays/firefox-addons.nix
  ];

  programs.librewolf = {
    enable = true;
    profiles = {
      camdenboren = {
        settings = {
          "browser.startup.homepage" = homepage;
          "browser.toolbars.bookmarks.visibility" = "never";
          "browser.urlbar.suggest.bookmark" = false;
          "browser.urlbar.suggest.history" = false;
          "browser.urlbar.suggest.openpage" = false;
          "browser.urlbar.suggest.topsites" = false;
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
          "privacy.clearOnShutdown_v2.cookiesAndStorage" = true;
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
          "browser.newtabpage.activity-stream.asrouter.userprefs.cfr.addons" = false;
          "browser.newtabpage.activity-stream.asrouter.userprefs.cfr.features" = false;
          "browser.newtabpage.activity-stream.feeds.topsites" = false;
          "extensions.formautofill.addresses.enabled" = false;
          "extensions.formautofill.creditCards.enabled" = false;
          "signon.rememberSignons" = false;
          "sidebar.verticalTabs" = true;
          "sidebar.revamp" = true;
          "sidebar.main.tools" = "";
          "sidebar.visibility" = "always-show";
        };

        extensions.packages = with pkgs.firefox-addons; [
          darkreader
          libredirect
          easy-container-shortcuts
          new-tab-override
          vimium
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
            "Nix Packages"
            "Nix Options"
            "Home Manager Options"
          ];

          engines = {
            "Nix Packages" = {
              icon = nixos-icon;
              definedAliases = [ "@np" ];
              urls = [
                {
                  template = "https://search.nixos.org/packages";
                  params = [
                    query
                    {
                      name = "type";
                      value = "packages";
                    }
                  ];
                }
              ];
            };

            "Nix Options" = {
              icon = nixos-icon;
              definedAliases = [ "@no" ];
              urls = [
                {
                  template = "https://search.nixos.org/options";
                  params = [
                    query
                    {
                      name = "type";
                      value = "options";
                    }
                  ];
                }
              ];
            };

            "Home Manager Options" = {
              icon = nixos-icon;
              definedAliases = [ "@hm" ];
              urls = [
                {
                  template = "https://home-manager-options.extranix.com";
                  params = [
                    query
                    {
                      name = "release";
                      value = "master";
                    }
                  ];
                }
              ];
            };
          };
        };
      };
    };
  };
}
