# ❄️ NixOS + Darwin Config ❄️

## Introduction

This is a config for multiple hosts of varying degrees of specificity, but main is an audio-oriented, modular NixOS configuration relying on Home-Manager and Flakes and includes examples of

- Derivations
- Overlays
- Development Environments
- Custom Scripts

Special thanks to [vimjoyer](https://github.com/vimjoyer/), [ryan4yin](https://github.com/ryan4yin/), and [PowerUser64](https://github.com/poweruser64/), as their content/configs were massively helpful for learning the basics of NixOS, flakes, home-manager, and linux audio

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

  <i>`usr` also includes subdirectories for dotfiles, custom derivations, development environments, scripts, and theming to enable convienent access. Some plugins are sourced locally due to a lack of availability of directly downloadable binaries</i>

### Systems

- #### mac

  - Development and Productivity
  - 2023 Macbook Pro 14"
  - M2 Pro
  - 1tb storage
  - 16gb memory

- #### main

  - Audio, Development and Productivity, Gaming
  - DIY build
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
  - 12gb memory

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

6. Main local plugin sourcing\
   _Instructions for local files, can do server instead once set up_\
   _Prepare the environment_

   ```shell
   {
   cd ~/Music/music/Plugins
   dev -p
   nix develop
   }
   ```

   _Then serve_

   ```shell
   python3 -m http.server
   ```

### Rebuild

```shell
sudo nixos-rebuild boot --flake ~/etc/nixos#hostName
```

<i>Librewolf, Freetube, Tidal-Hifi configs won't be updated until they've been launched<br>
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

  - Settings -> Keyboard -> Keyboard Shortcuts...

    - Display

      - Decrease display brightness = F1
      - Increaes display brightness = F2

    - Mission Control -> Mission Control

      - Move left a space = cmd-alt-left
      - Move right a space = cmd-alt-right

    - Services -> General

      - cmd-alt-letter for the following (requires automator services)
      - Bitwarden, ClickUp, FreeTube, Ghostty, LibreWolf, Notes, Slack, UTM, Zed

    - Spotlight

      - Show Spotlight search = ctrl-Space
      - Show Finder search window = ctrl-1

    - App Shortcuts -> All Applications

      - Minimize = ctrl-h

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

  - AutoRaise.app
  - BetterDisplay.app
  - Ice.app
  - LinearMouse.app
  - MullvadVPN.app
  - Rectangle.app

## Useful Commands

### Nix Management

- Rebuilds system based on flake in ~/etc/nixos

  ```shell
  nh os switch
  ```

- Uncomfy version

  ```shell
  sudo nixos-rebuild switch --flake ~/etc/nixos#hostName
  ```

- Updates flake inputs\
  _`cd` into directory first_

  ```shell
  nix flake update
  ```

- Evaluates flake outputs

  ```shell
  nix flake check
  ```

- Lists all current generations

  ```shell
  nix profile history
  ```

- Removes old generations, derivations, etc.

  ```shell
  sudo nix-collect-garbage -d
  nix-collect-garbage -d
  ```

- Removes gens older than 3 days

  ```shell
  nix-collect-garbage --delete-older-than 3d
  ```

- Build a nixpkgs-style derivations\
  _cd into directory first_

  ```shell
  nix-build -E "with import <nixpkgs> {}; callPackage ./default.nix {}"
  ```

- Try out a package w/o installing

  ```shell
  nix shell nixpkgs#packageName
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

- Verify Directory Integrity

  ```shell
  find . -type f -exec md5sum {} + | LC_ALL=C sort | md5sum >> md5sum.txt
  ```

- Initialize locate db

  ```shell
  sudo updatedb
  ```

- Remove rygel's ignored media files list (log out to take effect, also need: `nix shell nixpkgs#sqlite`)

  ```shell
  echo "delete from ignorelist;" | sqlite3 ~/.cache/rygel/media-export.db
  ```

- Mac Update

  ```shell
  darwin-rebuild switch --flake ~/etc/nixos
  brew upgrade
  brew cleanup
  xattr -d com.apple.quarantine /Applications/LibreWolf.app
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
  - Extra cmds

    ```shell
    protontricks --no-background-wineserver 244210 dotnet48
    ```

- #### Black Myth: Wukong

  - GE-Proton9-11

- #### GTAV

  - GEProton-9-19
  - Extra notes
    - <i>config saved in hm, manage pretty consistent 50-60fps
    - config path: `~/.steam/steam/steamapps/compatdata/271590/pfx/drive_c/users/steamuser/Documents/Rockstar\ Games/GTA\ V/settings.xml`</i>

- #### MCC

  - Proton 8.0-5

## ToDo

- [ ] local file workaround for vimium on new tabs https://peterries.net/blog/firefox-ubuntu-local-file/
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
