{
  lib,
  pkgs,
  ...
}:

{
  home.activation = {
    installPlugins = lib.hm.dag.entryAfter [ "installPackages" ] ''
      oldPath=$(run ${pkgs.yabridgectl}/bin/yabridgectl list)
      melda_pkg=${pkgs.maudioplugins} 
      melda_source="$melda_pkg/share/maudioplugins/programdata/MeldaProduction"
      melda_target="/home/camdenboren/.wine/drive_c/ProgramData/MeldaProduction"

      if ! [[ -z "$oldPath" ]]; then
        echo "Removing old store location..."
        run ${pkgs.yabridgectl}/bin/yabridgectl rm "$oldPath"

        echo "Syncing..."
        run ${pkgs.yabridgectl}/bin/yabridgectl sync
      fi

      if ! test -d ~/.wine; then
        echo "Calling wineboot for fresh prefix setup..."
        run env WINEDLLOVERRIDES=mscoree=d ${pkgs.wineWow64Packages.staging}/bin/wineboot -u
        echo -e "\nCalling 'winetricks dxvk' for fresh prefix setup...\n"
        run ${pkgs.winetricks}/bin/winetricks $VERBOSE_ARG dxvk
        echo -e "\nSetting DPI to 120 with regedit...\n"
        run ${pkgs.wineWow64Packages.staging}/bin/regedit ~/etc/nixos/hosts/main/usr/dot/wine/logpixels.reg
      fi

      if test -d "$melda_target"; then
        echo "Removing Melda plugin kernels from prefix..."
        run rm -r $VERBOSE_ARG "$melda_target"
      fi

      echo -e "Linking Melda plugin kernels to prefix...\n"
      run ln -sf $VERBOSE_ARG "$melda_source" "$melda_target"

      echo "Adding new store location..."
      run ${pkgs.yabridgectl}/bin/yabridgectl add ~/.nix-profile/lib/winvst3

      echo "Syncing..."
      run ${pkgs.yabridgectl}/bin/yabridgectl sync --prune
    '';

    replaceConfigs = lib.hm.dag.entryAfter [ "installPackages" ] ''
      if test -d ~/.config/FreeTube; then
        echo "Removing configs for: FreeTube"
        run rm -f $VERBOSE_ARG ~/.config/FreeTube/playlists.db
        run rm -f $VERBOSE_ARG ~/.config/FreeTube/profiles.db
        echo -e "Copying dotfiles for: FreeTube\n"
        run cp -r $VERBOSE_ARG ~/Documents/Repos/Notes/Media/Video/FreeTube/playlists.db ~/.config/FreeTube
        run cp -r $VERBOSE_ARG ~/Documents/Repos/Notes/Media/Video/FreeTube/profiles.db ~/.config/FreeTube
      fi

      if ! test -f ~/.config/REAPER/reaper.ini; then
        run mkdir -p $VERBOSE_ARG ~/.config/REAPER
        run cp -r $VERBOSE_ARG ~/etc/nixos/hosts/main/usr/dot/reaper/reaper.ini ~/.config/REAPER
      fi
    '';
  };
}
