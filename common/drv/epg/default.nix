{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  makeWrapper,
  nodejs,
}:

buildNpmPackage {
  pname = "epg";
  version = "0-unstable-2026-11-21";
  src = fetchFromGitHub {
    owner = "iptv-org";
    repo = "epg";
    rev = "1c3f51bb5958e24acf0dcb235d69d5635002a2d4";
    hash = "sha256-SDojiHJiIRr8Tm8feJu/5f0cyfDyfTYApHOYWpi3heE=";
  };

  npmDepsHash = "sha256-lrSP6oybhoVtGmZkcMJ+xBO9pF/VGRH7cMgnwZG+eyM=";

  nativeBuildInputs = [ makeWrapper ];

  # upstream's postinstall downloads the iptv-org API
  npmRebuildFlags = [ "--ignore-scripts" ];

  # no upstream `build` script; buildPhase compiles the TypeScript
  dontNpmBuild = true;

  # reclassify dev-only packages and drop the network lifecycle scripts
  postPatch = ''
    ${lib.getExe nodejs} ${./prepare.cjs}
  '';

  # avoid @swc-node/register: its self-extracting native addon needs a
  # writable cache and fails in the store, so ship compiled JavaScript instead
  buildPhase = ''
    runHook preBuild

    ${lib.getExe nodejs} node_modules/typescript/bin/tsc -p tsconfig.build.json --noCheck

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    # drop jest, eslint, typescript, @swc/core, and their unique dependencies
    npm prune --omit=dev --ignore-scripts --offline --no-audit --no-fund

    mkdir -p $out/lib/epg $out/bin

    cp -r dist node_modules sites package.json SITES.md LICENSE $out/lib/epg/

    # jest fixtures; ~80% of the `sites` tree
    rm -rf $out/lib/epg/sites/*/__data__

    cp ${./refresh.cjs} $out/lib/epg/refresh.cjs

    makeWrapper ${lib.getExe nodejs} $out/bin/epg \
      --add-flags "$out/lib/epg/dist/scripts/commands/epg/grab.js"

    makeWrapper ${lib.getExe nodejs} $out/bin/epg-refresh \
      --add-flags "$out/lib/epg/refresh.cjs" \
      --set-default SITES_DIR "$out/lib/epg/sites"

    runHook postInstall
  '';

  meta = {
    description = "Utilities for downloading the EPG (Electronic Program Guide) for thousands of TV channels from hundreds of sources";
    homepage = "https://github.com/iptv-org/epg";
    license = lib.licenses.unlicense;
    mainProgram = "epg";
    platforms = lib.platforms.all;
  };
}
