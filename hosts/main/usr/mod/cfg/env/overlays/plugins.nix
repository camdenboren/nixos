{ ... }:

{
  nixpkgs.overlays = [
    (final: prev: {
      audiogridder = prev.callPackage ../../../../drv/audiogridder { };
      sitala = prev.callPackage ../../../../drv/sitala { };
      neural-amp-modeler-lv2 = prev.callPackage ../../../../drv/neural-amp-modeler-lv2 { };
      loudmax = prev.callPackage ../../../../drv/loudmax { };
      ssq = prev.callPackage ../../../../drv/ssq { };
      britpressor = prev.callPackage ../../../../drv/britpressor { };
      fetish = prev.callPackage ../../../../drv/fetish { };
      rare = prev.callPackage ../../../../drv/rare { };
      kotelnikov = prev.callPackage ../../../../drv/kotelnikov { };
      nova = prev.callPackage ../../../../drv/nova { };
      freq-echo = prev.callPackage ../../../../drv/freq-echo { };
      span = prev.callPackage ../../../../drv/span { };
      ssd = prev.callPackage ../../../../drv/ssd { };
      maudioplugins = prev.callPackage ../../../../drv/maudioplugins { };
      abstract-vox = prev.callPackage ../../../../drv/abstract-vox { };
    })
  ];
}
