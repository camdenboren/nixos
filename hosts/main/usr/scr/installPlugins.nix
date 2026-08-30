{ pkgs }:

pkgs.writeShellScriptBin "installPlugins" ''
  oldPath=$(yabridgectl list)
  windows_path="/home/camdenboren/.wine/dosdevices/c:/windows"
  melda_pkg=${pkgs.maudioplugins}
  melda_source="$melda_pkg/share/maudioplugins/programdata/MeldaProduction"
  melda_target="/home/camdenboren/.wine/drive_c/ProgramData/MeldaProduction"

  if ! [[ -z "$oldPath" ]]; then
    echo "Removing old store location..."
    yabridgectl rm "$oldPath"

    echo "Syncing..."
    yabridgectl sync
  fi

  if ! test -d /home/camdenboren/.wine; then
    echo "Calling wineboot for fresh prefix setup..."
    env WINEDLLOVERRIDES=mscoree=d wineboot -u
    echo -e "\nSetting DPI to 120 with regedit..."
    regedit ~/etc/nixos/hosts/main/usr/dot/wine/logpixels.reg
  fi

  echo -e "\nUpdating dxvk dlls to latest..."
  for dll in dxgi d3d8 d3d9 d3d10core d3d11; do
    cp -f ${pkgs.dxvk-bin}/x32/$dll.dll $windows_path/syswow64/
    cp -f ${pkgs.dxvk-bin}/x64/$dll.dll $windows_path/system32/
  done
  ${pkgs.wineWow64Packages.yabridge}/bin/regedit ~/etc/nixos/hosts/main/usr/dot/wine/override-dll.reg
  echo ""

  if test -d "$melda_target"; then
    echo "Removing Melda plugin kernels from prefix..."
    rm -r "$melda_target"
  fi

  echo -e "Linking Melda plugin kernels to prefix...\n"
  ln -sf "$melda_source" "$melda_target"

  echo "Adding new store location..."
  yabridgectl add ~/.nix-profile/lib/winvst3

  echo "Syncing..."
  yabridgectl sync --prune
''
