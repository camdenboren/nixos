{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
}:

buildNpmPackage (finalAttrs: {
  pname = "pi-lsp";
  version = "0.49.10";
  src = fetchFromGitHub {
    owner = "narumiruna";
    repo = "pi-extensions";
    tag = "@narumitw/pi-lsp@${finalAttrs.version}";
    hash = "sha256-7GoThvSjC5VY14eTw+Sw8/gFz2LDOcveu4yV9+2PJKg=";
  };

  npmDepsHash = "sha256-9Nwa70IOumPl68bmg0XOLICkIzceVRj1b8n3G4Aj3+o=";
  npmWorkspace = "@narumitw/pi-lsp";

  installPhase = ''
    runHook preInstall
    mkdir -p "$out/lib/pi-lsp"
    cp -r packages/pi-lsp "$out/lib/"

    # reexport so tui shows `pi-lsp` rather than `dist`
    cat > "$out/lib/pi-lsp/index.ts" <<'EOF'
    export { default } from "./dist/index.ts";
    export * from "./dist/index.ts";
    EOF

    substituteInPlace "$out/lib/pi-lsp/package.json" \
      --replace-fail './dist/index.ts' './index.ts'
    runHook postInstall
  '';

  meta = {
    description = "A monorepo of Pi Coding Agent extensions";
    homepage = "https://github.com/narumiruna/pi-extensions";
    changelog = "https://github.com/narumiruna/pi-extensions/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
  };
})
