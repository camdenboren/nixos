{
  stdenv,
  fetchFromGitHub,
  cmake,
}:

stdenv.mkDerivation rec {
  pname = "neural-amp-modeler-lv2";
  version = "0.2.0";

  src = fetchFromGitHub {
    owner = "mikeoliphant";
    repo = "neural-amp-modeler-lv2";
    rev = "v${version}";
    fetchSubmodules = true;
    hash = "sha256-rwh4OGAIw/cLP8Q3kx8mqxUBM2FzLNf9blMgmkwnWpI=";
  };

  cmakeFlags = [
    "-DCMAKE_BUILD_TYPE=Release"
    "‑DUSE_NATIVE_ARCH=ON"
  ];

  nativeBuildInputs = [ cmake ];

  buildPhase = ''
    make -j $NIX_BUILD_CORES
  '';

  installPhase = ''
    mkdir -p $out/lib/lv2
    cp -r neural_amp_modeler.lv2 $out/lib/lv2
  '';
}
