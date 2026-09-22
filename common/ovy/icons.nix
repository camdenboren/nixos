{ rice, ... }:

{
  nixpkgs.overlays = [
    (_final: prev: {
      dracula-icon-theme = prev.dracula-icon-theme.overrideAttrs (o: {
        postInstall = (o.postInstall or "") + ''
          cp -f ${../usr/rice/icons/librewolf/librewolf-${rice}.svg} $out/share/icons/Dracula/scalable/apps/librewolf.svg

          cp -f ${../usr/rice/icons/ghostty/com.mitchellh.ghostty-${rice}.svg} $out/share/icons/Dracula/scalable/apps/com.mitchellh.ghostty.svg

          rm -f $out/share/icons/Dracula/scalable/apps/bitwarden.svg
          cp -f ${../usr/rice/icons/bitwarden/bitwarden-${rice}.svg} $out/share/icons/Dracula/scalable/apps/bitwarden.svg

          cp -f ${../usr/rice/icons/easyeffects/com.github.wwmm.easyeffects-${rice}.svg} $out/share/icons/Dracula/scalable/apps/com.github.wwmm.easyeffects.svg

          cp -f ${../usr/rice/icons/freetube/freetube-${rice}.svg} $out/share/icons/Dracula/scalable/apps/freetube.svg

          rm -f $out/share/icons/Dracula/scalable/apps/cockos-reaper.svg
          cp -f ${../usr/rice/icons/cockos-reaper/cockos-reaper.svg} $out/share/icons/Dracula/scalable/apps/cockos-reaper.svg

          rm -f $out/share/icons/Dracula/scalable/apps/inkscape.svg
          cp -f ${../usr/rice/icons/inkscape/inkscape.svg} $out/share/icons/Dracula/scalable/apps/inkscape.svg

          rm -f $out/share/icons/Dracula/scalable/apps/blender.svg
          cp -f ${../usr/rice/icons/blender/blender.svg} $out/share/icons/Dracula/scalable/apps/blender.svg

          rm -f $out/share/icons/Dracula/scalable/apps/gimp.svg
          cp -f ${../usr/rice/icons/gimp/gimp.svg} $out/share/icons/Dracula/scalable/apps/gimp.svg

          rm -f $out/share/icons/Dracula/scalable/apps/qbittorrent.svg
          cp -f ${../usr/rice/icons/qbittorrent/qbittorrent-${rice}.svg} $out/share/icons/Dracula/scalable/apps/qbittorrent.svg

          cp -f ${../usr/rice/icons/lollypop/org.gnome.Lollypop-${rice}.svg} $out/share/icons/Dracula/scalable/apps/org.gnome.Lollypop.svg

          rm -f $out/share/icons/Dracula/index.theme
          cp -f ${../usr/rice/icons/index.theme} $out/share/icons/Dracula/index.theme

          rm -f $out/share/icons/Dracula/22/panel/network-vpn-symbolic.svg
          cp -f ${../usr/rice/icons/vpn-status/22/connected.svg} $out/share/icons/Dracula/22/panel/network-vpn-symbolic.svg

          rm -f $out/share/icons/Dracula/22/panel/network-vpn-aquiring.svg
          cp -f ${../usr/rice/icons/vpn-status/22/connecting.svg} $out/share/icons/Dracula/22/panel/network-vpn-aquiring.svg

          rm -f $out/share/icons/Dracula/24/panel/network-vpn-symbolic.svg
          cp -f ${../usr/rice/icons/vpn-status/24/connected.svg} $out/share/icons/Dracula/24/panel/network-vpn-symbolic.svg

          rm -f $out/share/icons/Dracula/24/panel/network-vpn-aquiring.svg
          cp -f ${../usr/rice/icons/vpn-status/24/connecting.svg} $out/share/icons/Dracula/24/panel/network-vpn-aquiring.svg

          cp -f ${../usr/rice/icons/chat/chat.svg} $out/share/icons/Dracula/scalable/apps/chat.svg

          cp -f ${../usr/rice/icons/duck/duck-${rice}.svg} $out/share/icons/Dracula/scalable/apps/duck.svg

          cp -f ${../usr/rice/icons/mailbox/mailbox-${rice}.svg} $out/share/icons/Dracula/scalable/apps/mailbox.svg

          cp -f ${../usr/rice/icons/media/media-${rice}.svg} $out/share/icons/Dracula/scalable/apps/media.svg

          rm -f $out/share/icons/Dracula/scalable/apps/notes.svg
          cp -f ${../usr/rice/icons/notes/notes.svg} $out/share/icons/Dracula/scalable/apps/notes.svg

          rm -f $out/share/icons/Dracula/scalable/apps/photos.svg
          cp -f ${../usr/rice/icons/photos/photos.svg} $out/share/icons/Dracula/scalable/apps/photos.svg
        '';
      });
    })
  ];
}
