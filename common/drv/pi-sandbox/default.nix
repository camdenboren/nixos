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
  version = "0.7.2";

  src = fetchFromGitHub {
    owner = "carderne";
    repo = "pi-sandbox";
    tag = "v${finalAttrs.version}";
    hash = "sha256-xDsEIW+SKbecCCsAiGU7MlvQ4eHJV82VtDe7/FEU2pM=";
  };

  pnpmDeps =
    (fetchPnpmDeps.override {
      pnpm = pnpm_10;
    })
      {
        inherit (finalAttrs) pname version src;
        fetcherVersion = 4;
        hash = "sha256-AG27LaE8sNXbScB+eIWd47mAnaksmtBgPD9FZyocJJE=";
      };

  nativeBuildInputs = [
    nodejs
    pnpm_10
    (pnpmConfigHook.override {
      pnpm = pnpm_10;
    })
  ];

  # Pi loads this as an extension; it isn't an executable.
  installPhase = ''
    runHook preInstall

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
