# Modules

These custom modules expose `keybinds` and `rice` options to coordinate
shortcuts and appearance across applications on Linux and macOS.
[default.nix](default.nix) imports both modules, enables the keybinds, and applies
the host's theme. Each module generates the relevant application and desktop
settings; package installation and application enabling are handled elsewhere.

- [Keybinds](#keybinds): shared shortcuts, GNOME launchers, and macOS modifier mappings.
- [Rice](#rice): themes, fonts, colors, and Linux wallpaper.

## Keybinds

[keybinds.nix](keybinds.nix) gates its configuration with
`lib.mkIf config.keybinds.enable`. [default.nix](default.nix) imports it and
explicitly sets `keybinds.enable = true`.

To disable it while retaining the shared defaults, override that assignment in a
Home Manager module receiving `lib`:

```nix
keybinds.enable = lib.mkForce false;
```

### Platform behavior

| Target  | Configuration                                                                                                                                                        |
| ------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Ghostty | Quit/close and tab creation, navigation, and movement. Uses `ctrl`/`alt` on Linux and `cmd`/`opt` on Darwin; adds Darwin clipboard shortcuts.                        |
| Zed     | Reuses `bindings` in `Editor`, `Workspace`, and `Terminal` contexts; overrides close in `MessageEditor > Editor`. Adds Darwin Vim, clipboard, and minimize bindings. |
| GNOME   | Disables the logout shortcut, assigns shutdown, registers application launchers, and configures focus-changer left/right shortcuts.                                  |
| macOS   | Writes `targets.darwin.currentHostDefaults` modifier mappings that swap Command/Control for the three listed device IDs. Other OS shortcuts live in `macos.nix`.     |

`system` determines Darwin versus Linux; `hostname` ending in `vm` limits GNOME
launcher registration. All Linux hosts register LibreWolf, Ghostty, and Zed.
Non-VM hosts add FreeTube, VLC, Mullvad, Lollypop, Steam, and EasyEffects; only
`main` adds Reaper. Launchers use `<Control><Alt>` plus the letter in each entry.
These commands must be installed separately.

### Extend

- For a shared Zed shortcut, add a name/value pair to `bindings`; for a contextual
  shortcut, add it under the appropriate `userKeymaps` entry. Ghostty has a separate
  `settings.keybind` list and its own syntax.
- For a GNOME launcher, add a unique `customN` attribute with `name`, `command`, and
  `binding`, then register its full path in `custom-keybindings` under the correct
  host condition. Defining the entry alone does not register it.
- For another Mac device, inspect its ID with `defaults -currentHost read -g` and
  add the corresponding `com.apple.keyboard.modifiermapping.<id>` key using
  `modifierMapping`. The current list does not cover arbitrary devices.

Application appearance is documented separately in [rice.md](rice.md). After
changing shortcuts, rebuild the relevant host and check them in each affected
application/context; evaluating the module cannot detect shortcut conflicts.

## Rice

[rice.nix](rice.nix) defines the Home Manager `rice` string option, defaulting to
`"skyline"`. Supported themes are `coral`, `nothin`, and `skyline`.
[default.nix](default.nix) imports it and sets the option from the host's `rice`
argument, declared in `hosts/<host>/default.nix` and passed through special args.

```nix
# In a Home Manager module:
rice = "coral";
```

For a host-wide theme change, edit the host's `rice` binding: the
[icon overlay](../../../../ovy/icons.nix) and media dashboard read that argument
directly, rather than `config.rice`.

### Generated configuration

- `clr` and `fonts` supply Bash prompt/matrix colors, Ghostty's custom theme and
  palette, Zed fonts/theme selection, and LibreWolf profile colors/fonts.
- `home.file` generates Zed theme JSON and GTK 3/4 accent CSS.
- Linux additionally receives GNOME wallpaper and accent settings through dconf.
  Wallpaper URIs point to
  `/home/camdenboren/etc/nixos/common/usr/rice/wallpapers/${cfg}.jpg`.
- `system` controls Linux/macOS differences such as terminal opacity and Zed theme
  variants; a `hostname` ending in `vm` selects smaller Ghostty text.

The module combines shared and Linux-only attributes with `lib.recursiveUpdate`.
It configures applications; their installation/enabling is handled elsewhere.
Related shortcut settings are documented in [keybinds.md](keybinds.md).

### Add or adjust a theme

Edit `clr`, fonts, and application-specific selections in `rice.nix`. Terminal
palette keys have ordered prefixes because `lib.attrValues` supplies their order
before `imap0` assigns palette indices.

For a new theme name, also provide its wallpaper and every rice-dependent icon
asset, update the branches in this module and the media dashboard, and update the
option description. The option uses `types.str`, not an enum: unknown names take
the skyline color branches but still enter asset paths literally.

From the repository root, confirm the selected value before rebuilding:

```sh
nix eval --raw .#nixosConfigurations.media.config.home-manager.users.camdenboren.rice
```
