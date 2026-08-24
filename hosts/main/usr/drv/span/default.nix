{
  lib,
  stdenvNoCC,
  fetchurl,
  innoextract,
}:

stdenvNoCC.mkDerivation rec {
  pname = "span";
  version = "3.24";

  src = fetchurl {
    url = "https://www.voxengo.com/files/VoxengoSPAN_${
      lib.replaceStrings [ "." ] [ "" ] version
    }_Win32_64_VST_VST3_AAX_setup.exe";
    hash = "sha256-3GIiGo8HhBZa4P8Ugsapb5kRtdyeav6tpns9RvQ4XsI=";
  };

  nativeBuildInputs = [ innoextract ];

  dontConfigure = true;
  dontBuild = true;

  unpackPhase = ''
    runHook preUnpack
    innoextract --extract --silent "$src"
    runHook postUnpack
  '';

  installPhase = ''
    mkdir -p $out/lib/winvst3
    cp -r cf64/VST3/SPAN.vst3 $out/lib/winvst3
  '';

  passthru.updateScript = ./update.sh;
}
