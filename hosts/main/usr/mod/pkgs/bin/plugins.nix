{ pkgs, pkgs-stable, ... }:

{
  home.packages =
    with pkgs;
    [
      # Plugins - deps for winvsts
      #wineWowPackages.staging
      #winetricks
      #yabridge
      #yabridgectl
      # Plugins - custom derivations
      audiogridder
      sitala
      neural-amp-modeler-lv2
      loudmax
      # Plugins - windows via yabridge, put in lib/winvst3
      # try DPI 120 in winecfg if gui is buggy
      ssq
      britpressor
      fetish
      rare
      kotelnikov
      nova
      # Plugins - external
      freq-echo
      span
      ssd # needs dxvk via winetricks
      maudioplugins # needs music/Plugin\ Data/MeldaProduction put in ~/.wine/drive_c/ProgramData
      abstract-vox
      # Plugins - packs
      distrho-ports
      gxplugins-lv2
      lsp-plugins
      x42-plugins
      # Plugins - guitar
      proteus
      # Plugins - synth
      helm
      odin2
      cardinal
      surge-XT
      zynaddsubfx
      bespokesynth
      x42-gmsynth
      # Plugins - drum
      x42-avldrums
      drumgizmo
      hydrogen
      # Plugins - other
      #carla
      rnnoise-plugin
      noise-repellent
      sfizz
      fluidsynth
    ]
    ++ (with pkgs-stable; [
      # yabridge is broken on wine versions > 9.21 or so
      wineWowPackages.staging
      winetricks
      yabridge
      yabridgectl

      # carla is broken, see NixOS/nixpkgs#437077
      carla
    ]);
}
