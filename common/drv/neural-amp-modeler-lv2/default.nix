{
  stdenv,
  fetchFromGitHub,
  cmake,
}:

stdenv.mkDerivation rec {
  pname = "neural-amp-modeler-lv2";
  version = "0.2.3";

  src = fetchFromGitHub {
    owner = "mikeoliphant";
    repo = "neural-amp-modeler-lv2";
    rev = "v${version}";
    fetchSubmodules = true;
    hash = "sha256-TkynGmhwnkTqieJNuC+H2rDgxYZ9IFvqukfmtbSj790=";
  };

  cmakeFlags = [
    "-DCMAKE_BUILD_TYPE=Release"
    "-DUSE_NATIVE_ARCH=ON"
  ];

  # fixes a a use-after-free in `Plugin::work_response()`, which was crashing
  # REAPER when closing projects w/ bypassed plugin instances; more
  # specifically: REAPER skips bypassed FX (no run/notify), leaving the
  # model-load worker pending; on project close it deletes the plugin, then
  # delivers the response to the dead handle. work_response() then writes
  # currentModelPath/schedule through freed memory -> crash
  patches = [ ./model-path-fix.patch ];

  nativeBuildInputs = [ cmake ];

  buildPhase = ''
    make -j $NIX_BUILD_CORES
  '';

  installPhase = ''
    mkdir -p $out/lib/lv2
    cp -r neural_amp_modeler.lv2 $out/lib/lv2
  '';
}
