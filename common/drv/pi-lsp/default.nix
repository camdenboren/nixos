{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
}:

buildNpmPackage (finalAttrs: {
  pname = "pi-lsp";
  version = "0.49.12";
  src = fetchFromGitHub {
    owner = "narumiruna";
    repo = "pi-extensions";
    tag = "@narumitw/pi-lsp@${finalAttrs.version}";
    hash = "sha256-W+XXL1c8BbH0xuZCiZrv4G4TYlz9SBAbFaxvq/siySE=";
  };

  npmDepsHash = "sha256-xikjdJxkHUN74weNADG9FSdZS8uBuJRYXGpd9qpmn0E=";
  npmWorkspace = "@narumitw/pi-lsp";
  npmInstallFlags = [ "--workspace=${finalAttrs.npmWorkspace}" ];

  # drop sibling workspaces so npm doesn't install or retain their dependencies
  postPatch = ''
    find packages -mindepth 1 -maxdepth 1 ! -name pi-lsp -exec rm -rf {} +
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p "$out/lib/pi-lsp"
    cp -r packages/pi-lsp "$out/lib/"

    # runtime deps (e.g. cross-spawn) are hoisted to the workspace root by npm;
    # omit peer deps too since pi provides @earendil-works/* and typebox
    npm prune --omit=dev --omit=peer --no-save
    rm -rf node_modules/@narumitw
    find node_modules -maxdepth 1 -type d -empty -delete
    cp -r node_modules "$out/lib/pi-lsp/"

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
