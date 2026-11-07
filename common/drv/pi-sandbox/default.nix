{
  lib,
  stdenv,
  fetchFromGitHub,
  pnpm_10,
  pnpmConfigHook,
  fetchPnpmDeps,
  nodejs,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "pi-sandbox";
  version = "0.8.0";

  src = fetchFromGitHub {
    owner = "carderne";
    repo = "pi-sandbox";
    tag = "v${finalAttrs.version}";
    hash = "sha256-yTJyhh+MKmoFfYj2kKsfo3/3JXEQ4FTtes3MEdut/wg=";
  };

  pnpmDeps =
    (fetchPnpmDeps.override {
      pnpm = pnpm_10;
    })
      {
        inherit (finalAttrs) pname version src;
        fetcherVersion = 4;
        hash = "sha256-3u4p8LymmyCoPTS2YzKw9PTvUH9Ve2JNZMw97VGYywc=";
      };

  nativeBuildInputs = [
    nodejs
    pnpm_10
    (pnpmConfigHook.override {
      pnpm = pnpm_10;
    })
  ];

  # Pi loads this as an extension; it isn't an executable.
  # only runtime dependencies; devDependencies include pi itself
  installPhase = ''
    runHook preInstall

    pnpm prune --prod

    mkdir -p "$out/lib/pi-sandbox"
    cp -r index.ts src package.json node_modules "$out/lib/pi-sandbox/"

    runHook postInstall
  '';

  meta = {
    description = "OS-level sandboxing for pi with interactive permission prompts";
    homepage = "https://github.com/carderne/pi-sandbox";
    changelog = "https://github.com/carderne/pi-sandbox/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
  };
})
