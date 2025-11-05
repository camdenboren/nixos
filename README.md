# ❄️ NixOS + Darwin Config ❄️

[![built with garnix](https://img.shields.io/endpoint.svg?url=https%3A%2F%2Fgarnix.io%2Fapi%2Fbadges%2Fcamdenboren%2Fnixos%3Fbranch%3Dmain&style=for-the-badge&color=grey&labelColor=grey)](https://garnix.io/repo/camdenboren/nixos)

## Introduction

This is a config for multiple hosts of varying degrees of specificity, but `main` is an audio-oriented, modular NixOS configuration relying on Home-Manager and Flakes and includes examples of

- Custom Modules
- Custom Scripts
- Derivations
- Overlays
- DevShells

You probably won't want to try installing any of these hosts directly due to UUID discrepancies in `hardware-configuration.nix`, so this repo primarily serves as a reference in creating your own config

Some direct utility may be found in leveraging the binary cache by adding [Garnix] to your nix-config

```nix
nix.settings.substituters = [ "https://cache.garnix.io" ];
nix.settings.trusted-public-keys = [ "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g=" ];
```

Special thanks to [vimjoyer], [ryan4yin], and [PowerUser64], as their content/configs were massively helpful for learning the basics of NixOS, flakes, home-manager, and linux audio

### Sections

- [Overview](#overview)
  - [Structure](#structure)
  - [Systems](#systems)
- [Installation](#installation)
  - [Setup](#setup)
  - [Rebuild](#rebuild)
  - [Post-Install](#post-install)
- [Useful Commands](#useful-commands)
  - [Nix Management](#nix-management)
  - [Audio](#audio)
  - [Misc](#misc)
- [Gaming](#gaming)
  - [Global](#global)
  - [Assetto Corsa](#assetto-corsa)
  - [Black Myth: Wukong](#black-myth-wukong)
  - [GTAV](#gtav)
  - [MCC](#mcc)
- [ToDo](#todo)

## Overview

### Structure

- Firstly, pinning our system inputs, `flake.nix` is a parent
- Beneath this, various `hosts` are defined with `sys` and `usr` (think `configuration.nix` and `home-manager.nix`)
- `sys` and `usr` are further divided into modules within their corresponding directories
- Modules used by more than one host are stored in `common`

  ```
  flake
  ├── common
  │   ├── sys
  │   └── usr
  └── hosts
          ├── mac
          │   ├── sys
          │   └── usr
          ├── macvm
          │   ├── sys
          │   └── usr
          ├── main
          │   ├── sys
          │   └── usr
          ├── mainvm
          │   ├── sys
          │   └── usr
          └── media
              ├── sys
              └── usr
  ```

  <i>`usr` also includes subdirectories for dotfiles, custom derivations, development environments, scripts, and theming to enable convienent access</i>

### Systems

- #### mac
  - Development and Productivity
  - 2023 Macbook Pro 14"
  - M2 Pro
  - 1tb storage
  - 16gb memory

- #### main
  - Audio, Development and Productivity, Gaming
  - 2024 DIY build
  - Ryzen 7 9700x
  - NVIDIA RTX 4070S
  - 4tb NVME storage
  - 32gb memory

- #### media
  - Media, Gaming
  - 2011 Dell Inspiron 660
  - Intel i7 2600k
  - AMD Radeon RX 570
  - 500gb SSD + 12tb HDD storage
  - 8gb memory

## Installation

### Setup

1. Enable experimental features by adding this to `/etc/nixos/configuration.nix`

   ```nix
   # Enable flakes
   nix.settings.experimental-features = [
     "nix-command"
     "flakes"
   ];
   ```

   Then rebuild

   ```shell
   sudo nixos-rebuild switch
   ```

2. Move `/etc/nixos` to `~/etc/nixos`, symlink new location to old\
   _Enable non-sudo config edits_

   ```shell
   {
   mkdir ~/etc
   sudo mv /etc/nixos ~/etc/
   sudo chown -R $(id -un):users ~/etc/nixos
   sudo ln -s ~/etc/nixos /etc/
   }
   ```

3. Download repo to `~/etc/nixos`

   ```shell
   {
   mv ~/etc/nixos ~/etc/nixos.backup
   cd ~/etc
   git clone https://github.com/camdenboren/nixos.git
   }
   ```

4. Download Notes to `~/Documents/Repos/Notes`\
   _Not needed on mac or vm's_

   ```shell
   {
   cd ~/Documents
   git clone https://github.com/camdenboren/Notes.git
   }
   ```

5. Update hardware UUID's in hardware-config. Use as needed\
   _UUID and sd\* can be found in Gnome Disks_

   ```shell
   sudo fdisk /dev/sdb
   sudo mkfs -t ext4 /dev/sdb
   sudo chown camdenboren:users ~/media -R
   ```

### Rebuild

```shell
sudo nixos-rebuild boot --flake ~/etc/nixos#hostName
```

<i>Freetube and Tidal-Hifi configs won't be updated until they've been launched<br>
So launch them, clean up config errors, restart</i>

### Post-Install

- #### VSTs
  - Install windows vsts on main\
    _Needs `~/Music/music` sourced from local server first_

    ```shell
    installPlugins
    ```

- #### macvm UTM setup
  - Initial
    - '+' sign -> virtualize -> linux<br>
    - boot iso image (aarch64)
    - 4g mem
    - default cores
    - don't check opengl acc
    - 64g drive
    - name=NixOS

  - Network
    - Emulated VLAN

  - Before Starting

    ```shell
    chmod u+rw /Users/camdenboren/Library/Containers/com.utmapp.UTM/Data/Documents/NixOS.utm/Data/efi_vars.fd
    ```

  - After Install
    - Clear iso from vm page

  - Display
    - upscaling=Linear<br>
    - start in fullscreen<br>
    - use 1920x1200 resolution<br>
    - virtio-gl-pci

- #### mac shortcuts
  - Amethyst
    - Delete all shortcuts except
      - Move focus to counter clockwise creen = cmd-shift-left
      - Move focus to clockwise screen = cmd-shift-right

    - Rm all layouts except: Floating
    - Disable: General -> Heads up Display

  - Settings -> Keyboard -> Keyboard Shortcuts...
    - Display
      - Decrease display brightness = F1
      - Increaes display brightness = F2

    - Mission Control -> Mission Control
      - Move left a space = cmd-alt-left
      - Move right a space = cmd-alt-right

    - Services -> General
      - cmd-alt-letter for the following (requires automator services)
      - Bitwarden, ClickUp, FreeTube, Ghostty, LibreWolf, Mullvad, Notes, Slack, UTM, Zed

    - Spotlight
      - Show Spotlight search = ctrl-Space
      - Show Finder search window = cmd-alt-1

    - App Shortcuts -> All Applications
      - Minimize = ctrl-h
      - Shut Down... = cmd-alt-shift-d

    - App Shortcuts -> Notes.app
      - Show Folders = ctrl-alt-s
      - Copy Style = ctrl-alt-shift-c
      - Note List Search... = ctrl-alt-shift-f

    - App Shortcuts -> Finder.app
      - Hide Sidebar = ctrl-alt-s
      - New Folder with Selection = ctrl-alt-n
      - Downloads = cmd-alt-d
      - New Finder Window = ctrl-shift-n

    - App Shortcuts -> Zed.app
      - Save All = ctrl-alt-shift-s

    - Modifier Keys
      - Control = cmd
      - Command = ctrl

- #### mac display scaling
  - 32" LG -> 2288 x 1287
  - 19" Acer -> 774 x 1376

- #### mac manual login items and accessibility access
  - Amethyst.app
  - AutoRaise.app
  - BetterDisplay.app
  - Ice.app
  - LinearMouse.app
  - MullvadVPN.app
  - Rectangle.app

## Useful Commands

### Nix Management

_More commands in `./common/usr/mod/pkgs/bin/coding/bash.nix`_

- Rebuilds system based on flake in `~/etc/nixos`

  ```shell
  sw
  ```

- Uncomfy version

  ```shell
  sudo nixos-rebuild switch --flake ~/etc/nixos#hostName
  ```

- Updates flake inputs

  ```shell
  update
  ```

- Evaluates flake outputs

  ```shell
  check
  ```

- Lists all current generations

  ```shell
  nix profile history
  ```

- Removes old generations, derivations, etc.

  ```shell
  clean
  ```

- Build a nixpkgs-style derivations\
  _cd into directory first_

  ```shell
  bld
  ```

- Try out a package w/o installing

  ```shell
  run packageName
  ```

- Enter a shell with a package w/o installing

  ```shell
  shell packageName
  ```

### Audio

- Basic yabridge commands

  ```shell
  yabridgectl list
  yabridgectl status
  yabridgectl add "~/path/to/winvsts"
  yabridgectl rm "~/path/to/winvsts"
  ```

- Installs windows vsts from `~/.nix-profile/lib/winvst3` via yabridge into `~/.vst3`

  ```shell
  installPlugins
  ```

- Installs added windows vsts, purges removed windows vsts

  ```shell
  refreshPlugins
  ```

- Shows audio limits

  ```shell
  ulimit -a
  ```

### Misc

- Inspect Home Manager errors

  ```shell
  systemctl status home-manager-camdenboren.service
  ```

- Verify directory integrity

  ```shell
  find . -type f -exec md5sum {} + | LC_ALL=C sort | md5sum >> md5sum.txt
  ```

- Remove Rygel's ignored media files list (log out to take effect, also need: `shell sqlite`)

  ```shell
  echo "delete from ignorelist;" | sqlite3 ~/.cache/rygel/media-export.db
  ```

- Mac update\
  _Zoom screen sharing permissions often break_

  ```shell
  sw
  brew upgrade
  brew cleanup
  ```

- Quickemu (no vpn for windows dl, scripts use opt `--status-quo`)

  ```shell
  {
  mkdir ~/vm
  cd ~/vm
  quickget windows 10
  quickget nixos 24.05 gnome
  }
  ```

- Reset gsettings xkb (fixes esc <-> caps remap)

  ```shell
  {
  gsettings reset org.gnome.desktop.input-sources xkb-options
  gsettings reset org.gnome.desktop.input-sources sources
  }
  ```

## Gaming

### Global

- Using Steam
- Launch cmds

  ```shell
  'gamemoderun MANGOHUD=1 %command%'
  ```

### Games

- #### Assetto Corsa
  - GE-Proton8-32
  - Content Manager + CSP: https://github.com/sakaki91/Sakaki-AC-Linux-Guide/
  - Extra cmds _(doesn't seem necessary anymore-here for reference)_

    ```shell
    protontricks --no-background-wineserver 244210 dotnet48
    ```

  - Input settings for Xbox One Controller
    - Speed Sensitivity = 65%
    - Steering Speed = 20%
    - Gamma = 300%
    - Filter = 60%
    - Deadzone = 10%

- #### Black Myth: Wukong
  - GE-Proton9-11

- #### GTAV Enhanced
  - Proton Experimental
  - Extra notes
    - Also requires `SteamDeck=1` launch cmd
    - <i>config saved in hm, manage consistent 60fps
    - config path: `~/.steam/steam/steamapps/compatdata/3240220/pfx/drive_c/users/steamuser/Documents/Rockstar\ Games/GTAV\ Enhanced/settings.xml`</i>

- #### MCC
  - Proton 8.0-5

## ToDo

- [x] nh vimjoyer thing
- [x] use aliases instead of scripts for basic stuff
- [x] services.xserver.xkb.options
- [x] use firefox options for librewolf
- [ ] integration tests
- [x] ollama service for macos
- [ ] GTAV Refresh readme cmd
- [ ] custom iso
- [ ] network lf transfer
- [ ] nixified homebrew
- [x] try vim ext for vsc (unplanned)
- [x] remap $ and 0 in nvim (unplanned)
- [x] add git plugin to nvim (unplanned)
- [ ] ssh aliases or whatever
- [ ] maybe pipes

## License

[GPLv3]

[Garnix]: https://garnix.io/
[vimjoyer]: https://github.com/vimjoyer/
[ryan4yin]: https://github.com/ryan4yin/
[PowerUser64]: https://github.com/poweruser64/
[GPLv3]: COPYING
