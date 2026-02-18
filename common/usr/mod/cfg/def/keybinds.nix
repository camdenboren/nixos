{
  config,
  lib,
  hostname,
  system,
  ...
}:

let
  cfg = config.keybinds;
  isVM = lib.hasSuffix "vm" hostname;
  isDarwin = lib.hasSuffix "-darwin" system;
  isLinux = !isDarwin;
  ctrl = if isDarwin then "cmd" else "ctrl";
  alt = if isDarwin then "opt" else "alt";
  keybindingsPath = "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/";
  bindings = builtins.listToAttrs [
    {
      name = "${ctrl}-p";
      value = "pane::ActivatePreviousItem";
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
  # 0x700000000 or'd w/ hex codes from:
  # https://developer.apple.com/library/archive/technotes/tn2450/_index.html
  #
  # technique from: https://github.com/midchildan/dotfiles/blob/main/nix/home/profiles/macos/keyboard.nix
  leftControl = lib.fromHexString "7000000e0"; # 30064771296
  leftCommand = lib.fromHexString "7000000e3"; # 30064771299
  rightControl = lib.fromHexString "7000000e4"; # 30064771300
  rightCommand = lib.fromHexString "7000000e7"; # 30064771303
  modifierMapping = [
    {
      HIDKeyboardModifierMappingDst = rightControl;
      HIDKeyboardModifierMappingSrc = rightCommand;
    }
    {
      HIDKeyboardModifierMappingDst = leftCommand;
      HIDKeyboardModifierMappingSrc = leftControl;
    }
    {
      HIDKeyboardModifierMappingDst = leftControl;
      HIDKeyboardModifierMappingSrc = leftCommand;
    }
    {
      HIDKeyboardModifierMappingDst = rightCommand;
      HIDKeyboardModifierMappingSrc = rightControl;
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
        programs.ghostty.settings.keybind = [
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

        programs.zed-editor.userKeymaps = [
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
          {
            context = "MessageEditor > Editor";
            bindings = {
              "${ctrl}-w" = "workspace::ToggleRightDock";
            };
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

      (
        lib.recursiveUpdate
          # linux
          (lib.optionalAttrs isLinux {
            dconf.settings = {
              "org/gnome/settings-daemon/plugins/media-keys" = {
                logout = [ ];
                shutdown = [ "<Control><Alt>Delete" ];
                custom-keybindings = [
                  "/${keybindingsPath}custom0/"
                  "/${keybindingsPath}custom1/"
                  "/${keybindingsPath}custom2/"
                ]
                ++ lib.optionals (!isVM) [
                  "/${keybindingsPath}custom3/"
                  "/${keybindingsPath}custom4/"
                  "/${keybindingsPath}custom5/"
                  "/${keybindingsPath}custom6/"
                  "/${keybindingsPath}custom7/"
                  "/${keybindingsPath}custom8/"
                ]
                ++ lib.optionals (hostname == "main") [
                  "/${keybindingsPath}custom9/"
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
                command = "freetube";
                binding = "<Control><Alt>f";
              };
              "${keybindingsPath}custom4" = {
                name = "VLC";
                command = "vlc";
                binding = "<Control><Alt>v";
              };
              "${keybindingsPath}custom5" = {
                name = "MullvadVPN";
                command = "mullvad-gui";
                binding = "<Control><Alt>m";
              };
              "${keybindingsPath}custom6" = {
                name = "High Tide";
                command = "high-tide";
                binding = "<Control><Alt>t";
              };
              "${keybindingsPath}custom7" = {
                name = "Steam";
                command = "steam";
                binding = "<Control><Alt>s";
              };
              "${keybindingsPath}custom8" = {
                name = "EasyEffects";
                command = "easyeffects";
                binding = "<Control><Alt>e";
              };
              "${keybindingsPath}custom9" = {
                name = "Reaper";
                command = "reaper";
                binding = "<Control><Alt>r";
              };

              "org/gnome/shell/extensions/focus-changer" = {
                focus-left = [ "<Shift><Alt>Left" ];
                focus-right = [ "<Shift><Alt>Right" ];
              };
            };
          })

          # macOS - most are set in macos.nix
          (
            lib.optionalAttrs isDarwin {
              # swap cmd <-> ctrl on all devices
              # grep for them via: $(defaults -currentHost read -g | grep keyboard -A 20)
              targets.darwin.currentHostDefaults = {
                "Apple Global Domain" = {
                  # internal keyboard
                  "com.apple.keyboard.modifiermapping.0-0-0" = modifierMapping;

                  # usb mouse
                  "com.apple.keyboard.modifiermapping.1133-49970-0" = modifierMapping;

                  # usb keyboard
                  "com.apple.keyboard.modifiermapping.9494-4-0" = modifierMapping;
                };
              };
            }
          )
      )
  );
}
