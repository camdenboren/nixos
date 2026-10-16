# adapted from:
# https://github.com/NixOS/nixpkgs/blob/nixos-unstable/pkgs/by-name/ac/actual-server/package.nix

{
  lib,
  stdenv,
  cctools,
  fetchFromGitHub,
  git,
  jq,
  makeBinaryWrapper,
  nodejs_24,
  python3,
  xcbuild,
  yarn-berry_4,
}:
let
  nodejs = nodejs_24;
  yarn-berry = yarn-berry_4.override { inherit nodejs; };
in
stdenv.mkDerivation (finalAttrs: {
  pname = "actual-cli";
  version = "26.10.0";
  src = fetchFromGitHub {
    name = "actualbudget-actual-source";
    owner = "actualbudget";
    repo = "actual";
    tag = "v${finalAttrs.version}";
    hash = "sha256-jBh6mrYVVX7dNz5rv/VO766ezIuwBmXbtRSKgUOkahc=";
  };

  nativeBuildInputs = [
    yarn-berry
    nodejs
    (yarn-berry.yarnBerryConfigHook.override { inherit nodejs; })
    (python3.withPackages (ps: [ ps.setuptools ])) # Used by node-gyp
    makeBinaryWrapper
    jq
    # lage (used by `yarn build:cli`) shells out to `git ls-tree` to
    # compute file hashes for its build cache.
    git
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    cctools
    xcbuild
  ];

  env = {
    # electron is allowlisted for postinstall scripts upstream; skip its
    # binary download since the cli never uses it.
    ELECTRON_SKIP_BINARY_DOWNLOAD = "1";
  };
  # during build, vite tries to access localhost
  __darwinAllowLocalNetworking = true;

  postPatch = ''
    # We bring our own yarn
    sed -i '/yarnPath:/d' .yarnrc.yml

    # sharp is allowlisted for postinstall scripts upstream, which would try
    # to download binaries. The cli build never uses it, so disable it.
    cat <<< $(${lib.getExe jq} '.dependenciesMeta."sharp".built = false' ./package.json) > ./package.json
  '';

  buildPhase = ''
    runHook preBuild

    export HOME=$(mktemp -d)

    # lage hashes source files via `git ls-tree HEAD`, so it needs a repo with
    # at least one commit.
    git -c init.defaultBranch=main init -q
    git add -A
    git -c user.email=nix@localhost -c user.name=nix commit -q --allow-empty -m "snapshot"

    yarn build:cli

    runHook postBuild
  '';

  missingHashes = ./missing-hashes.json;
  offlineCache = yarn-berry.fetchYarnBerryDeps {
    inherit (finalAttrs) src missingHashes;
    hash = "sha256-NYjJeQWeDsLsEme/gIkZzgwWaqpQNSfLeYgZHaPTuH8=";
  };

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin $out/share/actual-cli/packages/cli $out/share/actual-cli/packages/api

    # cli bundles everything except @actual-app/api, and api bundles
    # everything except better-sqlite3, so these two workspaces plus the
    # production node_modules are all that's needed at runtime.
    cp -r ./packages/cli/dist ./packages/cli/package.json $out/share/actual-cli/packages/cli/
    cp -r ./packages/api/dist ./packages/api/package.json $out/share/actual-cli/packages/api/
    # `yarn workspaces focus` keeps workspace links for api's dependencies;
    # keep their targets around so the links don't dangle.
    cp -r ./packages/loot-core $out/share/actual-cli/packages/loot-core
    cp -r ./packages/crdt $out/share/actual-cli/packages/crdt

    # Re-create node_modules/ to contain just production packages required for
    # the cli itself, using existing offline cache.
    export HOME=$(mktemp -d)

    yarn workspaces focus @actual-app/cli --production
    rm -rf node_modules/.bin
    cp -r ./node_modules $out/share/actual-cli/

    makeBinaryWrapper ${lib.getExe nodejs} "$out/bin/actual-cli" \
      --add-flags "$out/share/actual-cli/packages/cli/dist/cli.js"

    # Upstream declares both bins; provide the `actual` alias too.
    ln -s actual-cli $out/bin/actual

    runHook postInstall
  '';

  passthru.updateScript = ./update.sh;

  meta = {
    description = "CLI for Actual Budget";
    homepage = "https://github.com/actualbudget/actual";
    changelog = "https://github.com/actualbudget/actual/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    mainProgram = "actual-cli";
    platforms = with lib.platforms; linux ++ darwin;
  };
})
