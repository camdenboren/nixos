{
  config,
  lib,
  hostname,
  system,
  ...
}:

let
  cfg = config.keybinds;
  isVM = lib.hasSuffix "-vm" hostname;
  isDarwin = lib.hasSuffix "-darwin" system;
  isLinux = !isDarwin;
  ctrl = if isDarwin then "cmd" else "ctrl";
  alt = if isDarwin then "opt" else "alt";
  keybindingsPath = "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/";
  bindings = builtins.listToAttrs [
    {
      name = "${ctrl}-p";
      value = "pane::ActivatePrevItem";
    }
    {
      name = "${ctrl}-n";
      value = "pane::ActivateNextItem";
    }
    {
      name = "${ctrl}-w";
      value = "pane::CloseActiveItem";
    }
    {
      name = "${ctrl}-q";
      value = "zed::Quit";
    }
    {
      name = "${ctrl}-shift-s";
      value = "workspace::ToggleLeftDock";
    }
    {
      name = "${ctrl}-shift-e";
      value = "project_panel::ToggleFocus";
    }
    {
      name = "${ctrl}-shift-g";
      value = "git_panel::ToggleFocus";
    }
    {
      name = "${ctrl}-e";
      value = "file_finder::Toggle";
    }
  ];
in
{
  options = {
    keybinds = {
      enable = lib.mkEnableOption {
        default = true;
        type = lib.types.bool;
      };
    };
  };

  config = lib.mkIf cfg.enable (
    lib.recursiveUpdate
      # all platforms
      {
        programs.ghostty.settings.keybind =
          [
            "${ctrl}+q=quit"
            "${ctrl}+w=close_surface"
            "${ctrl}+n=next_tab"
            "${ctrl}+p=previous_tab"
            "${ctrl}+t=new_tab"
            "${ctrl}+${alt}+n=move_tab:1"
            "${ctrl}+${alt}+p=move_tab:-1"
          ]
          ++ lib.optionals isDarwin [
            "${ctrl}+shift+c=copy_to_clipboard"
            "${ctrl}+shift+v=paste_from_clipboard"
          ];

        programs.zed-editor.userKeymaps =
          [
            {
              context = "Editor";
              inherit bindings;
            }
            {
              context = "Workspace";
              inherit bindings;
            }
            {
              context = "Terminal";
              inherit bindings;
            }
          ]
          ++ lib.optionals isDarwin [
            {
              context = "vim_mode == normal";
              bindings = {
                cmd-r = "vim::Redo";
                cmd-a = "vim::Increment";
                cmd-x = "vim::Decrement";
              };
            }
            {
              context = "VimControl && !menu";
              bindings = {
                cmd-f = "vim::PageDown";
                cmd-b = "vim::PageUp";
                cmd-d = "vim::ScrollDown";
                cmd-u = "vim::ScrollUp";
                "cmd-]" = "editor::GoToDefinition";
                cmd-m = "vim::NextLineStart";
              };
            }
            {
              context = "Terminal";
              bindings = {
                cmd-shift-c = "terminal::Copy";
                cmd-shift-v = "terminal::Paste";
              };
            }
            {
              context = "Editor";
              bindings = {
                ctrl-h = "zed::Minimize";
              };
            }
          ];
      }

      # linux
      (
        lib.optionalAttrs isLinux {
          dconf.settings = {
            "org/gnome/settings-daemon/plugins/media-keys" = {
              custom-keybindings =
                [
                  "/${keybindingsPath}custom0/"
                  "/${keybindingsPath}custom1/"
                  "/${keybindingsPath}custom2/"
                ]
                ++ lib.optionals (!isVM) [
                  "/${keybindingsPath}custom3/"
                  "/${keybindingsPath}custom4/"
                ]
                ++ lib.optionals (hostname == "main") [
                  "/${keybindingsPath}custom5/"
                ];
            };
            "${keybindingsPath}custom0" = {
              name = "LibreWolf";
              command = "librewolf";
              binding = "<Control><Alt>l";
            };
            "${keybindingsPath}custom1" = {
              name = "Ghostty";
              command = "ghostty";
              binding = "<Control><Alt>g";
            };
            "${keybindingsPath}custom2" = {
              name = "Zed";
              command = "zeditor";
              binding = "<Control><Alt>z";
            };
            "${keybindingsPath}custom3" = {
              name = "FreeTube";
              command = "freetube --disable-gpu";
              binding = "<Control><Alt>f";
            };
            "${keybindingsPath}custom4" = {
              name = "VLC";
              command = "vlc";
              binding = "<Control><Alt>v";
            };
            "${keybindingsPath}custom5" = {
              name = "Reaper";
              command = "reaper";
              binding = "<Control><Alt>r";
            };

            "org/gnome/shell/extensions/focus-changer" = {
              focus-left = [ "<Shift><Alt>Left" ];
              focus-right = [ "<Shift><Alt>Right" ];
            };
          };
        }
      )
  );
}
