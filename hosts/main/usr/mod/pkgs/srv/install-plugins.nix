{ pkgs, ... }:

let
  script = pkgs.writeShellScriptBin "install-plugins" ''
    oldPath=$(${pkgs.yabridgectl}/bin/yabridgectl list)
    windows_path="/home/camdenboren/.wine/dosdevices/c:/windows"
    melda_pkg=${pkgs.maudioplugins}
    melda_source="$melda_pkg/share/maudioplugins/programdata/MeldaProduction"
    melda_target="/home/camdenboren/.wine/drive_c/ProgramData/MeldaProduction"

    if ! [[ -z "$oldPath" ]]; then
      echo "Removing old store location..."
      ${pkgs.yabridgectl}/bin/yabridgectl rm "$oldPath"

      echo "Syncing..."
      ${pkgs.yabridgectl}/bin/yabridgectl sync
    fi

    if ! test -d /home/camdenboren/.wine; then
      echo "Calling wineboot for fresh prefix setup..."
      ${pkgs.coreutils}/bin/env WINEDLLOVERRIDES=mscoree=d ${pkgs.wineWow64Packages.yabridge}/bin/wineboot -u
      echo -e "\nSetting DPI to 120 with regedit..."
      ${pkgs.wineWow64Packages.yabridge}/bin/regedit ~/etc/nixos/hosts/main/usr/dot/wine/logpixels.reg
    fi

    echo -e "\nUpdating dxvk dlls to latest..."
    for dll in dxgi d3d8 d3d9 d3d10core d3d11; do
      ${pkgs.coreutils}/bin/cp -f ${pkgs.dxvk-bin}/x32/$dll.dll $windows_path/syswow64/
      ${pkgs.coreutils}/bin/cp -f ${pkgs.dxvk-bin}/x64/$dll.dll $windows_path/system32/
    done
    ${pkgs.wineWow64Packages.yabridge}/bin/regedit ~/etc/nixos/hosts/main/usr/dot/wine/override-dll.reg
    echo ""

    if test -d "$melda_target"; then
      echo "Removing Melda plugin kernels from prefix..."
      ${pkgs.coreutils}/bin/rm -r "$melda_target"
    fi

    echo -e "Linking Melda plugin kernels to prefix...\n"
    ${pkgs.coreutils}/bin/ln -sf "$melda_source" "$melda_target"

    echo "Adding new store location..."
    ${pkgs.yabridgectl}/bin/yabridgectl add ~/.nix-profile/lib/winvst3

    echo "Syncing..."
    ${pkgs.yabridgectl}/bin/yabridgectl sync --prune
  '';
in
{
  # Syncs yabridge plugins and the Wine prefix at login.
  systemd.user.services.install-plugins = {
    Unit = {
      Description = "Sync yabridge plugins and Wine prefix";
      # Re-sync when any audio plugin package changes.
      X-Restart-Triggers = (import ../bin/plugins.nix { inherit pkgs; }).home.packages;
    };
    Service = {
      Type = "oneshot";
      RemainAfterExit = true;
      # yabridgectl locates its chainloaders via NIX_PROFILES
      Environment = "NIX_PROFILES=\"/run/current-system/sw /nix/var/nix/profiles/default /etc/profiles/per-user/camdenboren /home/camdenboren/.nix-profile\"";
      ExecStart = "${script}/bin/install-plugins";
      NoNewPrivileges = true;
      ProtectSystem = true;
      UMask = "0027";
    };
    Install.WantedBy = [ "default.target" ];
  };
}
