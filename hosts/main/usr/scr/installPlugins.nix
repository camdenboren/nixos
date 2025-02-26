{ pkgs }:

pkgs.writeShellScriptBin "installPlugins" ''
  if ! test -d ~/.wine; then
    echo "Calling wineboot for fresh prefix setup..."
    wineboot -u
    echo -e "\nCalling 'winetricks dxvk' for fresh prefix setup...\n"
    winetricks dxvk
    echo -e "\nSetting DPI to 120 with regedit...\n"
    regedit ~/etc/nixos/hosts/main/usr/dot/wine/logpixels.reg
  fi
  if ! test -d ~/.wine/drive_c/ProgramData/MeldaProduction; then
    echo -e "Melda plugin kernels missing from prefix..."
    if test -d ~/Music/music/Plugins/Plugin\ Data/MeldaProduction; then
      echo -e "Linking Melda plugin kernels to prefix...\n"
      ln -s ~/Music/music/Plugins/Plugin\ Data/MeldaProduction ~/.wine/drive_c/ProgramData/MeldaProduction
    else
      echo -e "Melda plugin kernels missing from Music/music/Plugin Data/\n"
    fi
  fi
  echo "Adding new store location..."
  yabridgectl add ~/.nix-profile/lib/winvst3
  echo "Syncing..."
  yabridgectl sync --prune
''
