{
  lib,
  stdenv,
  fetchFromGitHub,
  pnpm_11,
  pnpmConfigHook,
  fetchPnpmDeps,
  nodejs,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "pi-permission-system";
  version = "41.0.0";

  src = fetchFromGitHub {
    owner = "gotgenes";
    repo = "pi-packages";
    tag = "pi-permission-system-v${finalAttrs.version}";
    hash = "sha256-+8/I2IagzL4dG8CXK2WzcDn4v8FTop27AKBfwVbm4Z8=";
  };

  pnpmDeps =
    (fetchPnpmDeps.override {
      pnpm = pnpm_11;
    })
      {
        inherit (finalAttrs) pname version src;
        fetcherVersion = 4;
        hash = "sha256-BBWqbhcEQ1k29qk88IJLVRI5L/ri+YWHVeuBbAk5D3s=";
      };

  nativeBuildInputs = [
    nodejs
    pnpm_11
    (pnpmConfigHook.override {
      pnpm = pnpm_11;
    })
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/lib/pi-permission-system"
    cp -a \
      packages/pi-permission-system/{package.json,src,node_modules} \
      "$out/lib/pi-permission-system/"

    # the package's pnpm symlinks point into the workspace-root virtual store
    mkdir -p "$out/node_modules"
    cp -a node_modules/.pnpm "$out/node_modules/"
    rm -rf "$out/node_modules/.pnpm/node_modules/@gotgenes"

    # reexport so tui shows `pi-permission-system` rather than `src`
    cat > "$out/lib/pi-permission-system/index.ts" <<'EOF'
    export { default } from "./src/index.ts";
    export * from "./src/index.ts";
    EOF

    substituteInPlace "$out/lib/pi-permission-system/package.json" \
      --replace-fail './src/index.ts' './index.ts'

    runHook postInstall
  '';

  meta = {
    description = "Monorepo for @gotgenes pi packages";
    homepage = "https://github.com/gotgenes/pi-packages";
    changelog = "https://github.com/gotgenes/pi-packages/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
  };
})
