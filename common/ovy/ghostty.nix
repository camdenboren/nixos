_:

{
  nixpkgs.overlays = [
    (_final: prev: {
      # `DBusActivatable=true` is causing problems when launching via
      # `.desktop` in GNOME, and this seems to fix it;
      # adapted from:
      # https://github.com/nix-community/home-manager/issues/8981
      ghostty = prev.ghostty.overrideAttrs (old: {
        postFixup = (old.postFixup or "") + ''
          desktop="$out/share/applications/com.mitchellh.ghostty.desktop"

          if [ -f "$desktop" ]; then
            substituteInPlace "$desktop" \
              --replace-fail 'DBusActivatable=true' 'DBusActivatable=false'
          fi
        '';
      });
    })
  ];
}
