{ rice, ... }:

{
  nixpkgs.overlays = [
    (final: prev: {
      dracula-icon-theme = prev.dracula-icon-theme.overrideAttrs (o: {
        postInstall = (o.postInstall or "") + ''
          cp -f ${../../../../rice/icons/librewolf/librewolf-${rice}.svg} $out/share/icons/Dracula/scalable/apps/librewolf.svg

          cp -f ${../../../../rice/icons/ghostty/com.mitchellh.ghostty.svg} $out/share/icons/Dracula/scalable/apps/com.mitchellh.ghostty.svg

          rm -f $out/share/icons/Dracula/scalable/apps/bitwarden.svg
          cp -f ${../../../../rice/icons/bitwarden/bitwarden-${rice}.svg} $out/share/icons/Dracula/scalable/apps/bitwarden.svg

          cp -f ${../../../../rice/icons/easyeffects/com.github.wwmm.easyeffects-${rice}.svg} $out/share/icons/Dracula/scalable/apps/com.github.wwmm.easyeffects.svg

          cp -f ${../../../../rice/icons/freetube/freetube-${rice}.svg} $out/share/icons/Dracula/scalable/apps/freetube.svg

          rm -f $out/share/icons/Dracula/scalable/apps/cockos-reaper.svg
          cp -f ${../../../../rice/icons/cockos-reaper/cockos-reaper.svg} $out/share/icons/Dracula/scalable/apps/cockos-reaper.svg

          rm -f $out/share/icons/Dracula/scalable/apps/vlc.svg
          cp -f ${../../../../rice/icons/vlc/vlc-${rice}.svg} $out/share/icons/Dracula/scalable/apps/vlc.svg

          rm -f $out/share/icons/Dracula/scalable/apps/inkscape.svg
          cp -f ${../../../../rice/icons/inkscape/inkscape.svg} $out/share/icons/Dracula/scalable/apps/inkscape.svg

          rm -f $out/share/icons/Dracula/scalable/apps/blender.svg
          cp -f ${../../../../rice/icons/blender/blender.svg} $out/share/icons/Dracula/scalable/apps/blender.svg

          rm -f $out/share/icons/Dracula/scalable/apps/gimp.svg
          cp -f ${../../../../rice/icons/gimp/gimp.svg} $out/share/icons/Dracula/scalable/apps/gimp.svg

          rm -f $out/share/icons/Dracula/scalable/apps/qbittorrent.svg
          cp -f ${../../../../rice/icons/qbittorrent/qbittorrent-${rice}.svg} $out/share/icons/Dracula/scalable/apps/qbittorrent.svg

          cp -f ${../../../../rice/icons/high-tide/io.github.nokse22.high-tide-${rice}.svg} $out/share/icons/Dracula/scalable/apps/io.github.nokse22.high-tide.svg

          rm -f $out/share/icons/Dracula/index.theme
          cp -f ${../../../../rice/icons/index.theme} $out/share/icons/Dracula/index.theme

          rm -f $out/share/icons/Dracula/22/panel/network-vpn-symbolic.svg
          cp -f ${../../../../rice/icons/vpn-status/22/connected.svg} $out/share/icons/Dracula/22/panel/network-vpn-symbolic.svg

          rm -f $out/share/icons/Dracula/22/panel/network-vpn-aquiring.svg
          cp -f ${../../../../rice/icons/vpn-status/22/connecting.svg} $out/share/icons/Dracula/22/panel/network-vpn-aquiring.svg

          rm -f $out/share/icons/Dracula/24/panel/network-vpn-symbolic.svg
          cp -f ${../../../../rice/icons/vpn-status/24/connected.svg} $out/share/icons/Dracula/24/panel/network-vpn-symbolic.svg

          rm -f $out/share/icons/Dracula/24/panel/network-vpn-aquiring.svg
          cp -f ${../../../../rice/icons/vpn-status/24/connecting.svg} $out/share/icons/Dracula/24/panel/network-vpn-aquiring.svg
        '';
      });
    })
  ];
}
