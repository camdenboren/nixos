{
  lib,
  stdenv,
  fetchFromGitHub,
}:

stdenv.mkDerivation {
  pname = "omdb-lookup";
  version = "0-unstable-2026-10-30";
  __structuredAttrs = true;
  strictDeps = true;

  src = fetchFromGitHub {
    owner = "camdenboren";
    repo = "OMDb_Lookup";
    rev = "b856139c8b2d493087818be0695f579666f86e01";
    hash = "sha256-0uxDV2UPSyLW6BbYsPtHoHgSJPSJ0S1u/Po6sFitwQ0=";
  };

  installPhase = ''
    runHook preInstall

    mkdir -p $out
    cp -r docs/* worker/* $out
    cp ${./config.capnp} $out/config.capnp

    substituteInPlace "$out/app.js" \
      --replace-fail \
      'https://omdb-lookup.boren-camden.workers.dev' \
      '/api'

    runHook postInstall
  '';

  meta = {
    description = "A simple widget to retrieve the top result for a given name and title from the OMDb API";
    homepage = "https://github.com/camdenboren/OMDb_Lookup";
    license = lib.licenses.mpl20;
    mainProgram = "omdb-lookup";
    platforms = lib.platforms.all;
  };
}
