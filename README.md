# ❄️ NixOS + Nix-Darwin Config ❄️

![Dynamic Badge](https://img.shields.io/github/actions/workflow/status/camdenboren/nixos/build.yaml?branch=main&style=for-the-badge)

## Introduction

This is a cross-platform config for multiple hosts of varying degrees of specificity and includes examples of

- [Modules]
- [Scripts]
- [Derivations]
- [Overlays]
- [DevShells]

The hosts cumulatively form a [Homelab] of every-increasing scope, w/ `media` acting as the primary server, though auxiliary tasks are delegated out (e.g., `main` handles virtually all local AI inference)

_You probably won't want to try installing any of these hosts directly due to UUID discrepancies in `hardware-configuration.nix`, so this repo primarily serves as a reference in creating your own config_

Special thanks to [vimjoyer], [ryan4yin], and [PowerUser64], as their content/configs were massively helpful for learning the basics of NixOS, flakes, home-manager, and Linux audio

## Structure

- Firstly, pinning our system inputs, `flake.nix` is a parent
- Beneath this, various `hosts` are defined with `sys` and `usr` (think `configuration.nix` and `home-manager.nix`)
- `sys` and `usr` are further divided into modules within their corresponding directories
- Modules used by more than one host are stored in `common`, as are all overlays and custom packages

  ```
  flake
  ├── common
  │   ├── drv
  │   ├── ovy
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

  _`usr` also includes subdirectories for dotfiles, custom derivations, development environments, scripts, and theming to enable convenient access_

## Systems

- ### mac
  - Development + Productivity
  - 2023 MacBook Pro 14"
  - M2 Pro
  - 1tb storage
  - 16gb memory

- ### main
  - Audio, Development + Productivity, Gaming
  - 2024 DIY build
  - Ryzen 7 9700x
  - NVIDIA RTX 4070S
  - 4tb NVME storage
  - 32gb memory

- ### media
  - Server, Gaming
  - 2011 Dell Inspiron 660
  - Intel i7 2600k
  - AMD Radeon RX 570
  - 500gb SSD + 12tb HDD storage
  - 8gb memory

## License

[GPLv3]

[Modules]: common/usr/mod/cfg/def/README.md
[Scripts]: common/usr/scr/README.md
[Derivations]: common/drv/README.md
[Overlays]: common/ovy/README.md
[DevShells]: common/usr/dev/README.md
[Homelab]: hosts/media/sys/mod/pkgs/srv/README.md
[vimjoyer]: https://github.com/vimjoyer/
[ryan4yin]: https://github.com/ryan4yin/
[PowerUser64]: https://github.com/poweruser64/
[GPLv3]: COPYING
