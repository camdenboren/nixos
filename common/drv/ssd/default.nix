{
  lib,
  stdenv,
  fetchzip,
  kits ? [ ],
}:

stdenv.mkDerivation {
  pname = "ssd";
  version = "5.5";
  src = fetchzip {
    url = "https://www.dropbox.com/scl/fi/f4y18v2jcq3p3b7s58x0e/ssd.tar.gz?rlkey=igznyvi3dv54srutmb6qtnnsm&st=be25mr0y&dl=1";
    hash = "sha256-3DCtUmHU8e7Emxt1Aix7AIYpq9cFoH5UwiNa0Ay2PJ0=";
    stripRoot = false;
  };

  ssdlib = fetchzip {
    url = "https://www.dropbox.com/scl/fi/5h9bq19or1y53mp3cyc1e/ssdlib.tar.gz?rlkey=f2pwtac07at92kyjz5hzn0ksh&st=3c8zenpy&dl=1";
    hash = "sha256-G0vigNA1a4YgaKazAFqMXe7ewZfkei0QDEszdCkJqGM=";
    stripRoot = false;
  };

  installPhase = ''
    winvst3="$out/lib/winvst3"
    samples="$out/share/samples"
    mkdir -p "$winvst3" "$samples"
    cp -r $src/ssd/SSDSampler5.vst3 "$winvst3"
    cp -r $ssdlib/SSD5Library "$samples"
  ''
  + lib.optionalString (kits != [ ]) (
    ''
      chmod -R u+w "$samples/SSD5Library"
      presets="$samples/SSD5Library/DrumKitPresets/User.lib"
      mkdir -p "$presets"
    ''
    + lib.concatMapStrings (kit: ''
      cp ${kit} "$presets/${baseNameOf kit}"
    '') kits
  );

  passthru.samplesPath = "share/samples/SSD5Library";
}
