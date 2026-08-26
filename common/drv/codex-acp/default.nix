{
  lib,
  buildNpmPackage,
  codex,
  fetchFromGitHub,
  makeBinaryWrapper,
  versionCheckHook,
}:

buildNpmPackage (finalAttrs: {
  pname = "codex-acp";
  version = "1.2.0";

  src = fetchFromGitHub {
    owner = "agentclientprotocol";
    repo = "codex-acp";
    tag = "v${finalAttrs.version}";
    hash = "sha256-RLspxhj5PTCKhRhlxhL4vALWED+qILfN6AdIyWetIHE=";
  };

  npmDepsHash = "sha256-JeRtgB7tDlshLeRGoRd1XSvW2QuKIOyJcc1aWUdt/3s=";

  nativeBuildInputs = [ makeBinaryWrapper ];

  postInstall = ''
    # Use the source-built Nixpkgs package instead of npm's bundled Codex binaries.
    rm -r $out/lib/node_modules/@agentclientprotocol/codex-acp/node_modules/@openai/codex*
    rm $out/lib/node_modules/@agentclientprotocol/codex-acp/node_modules/.bin/codex
    wrapProgram $out/bin/codex-acp \
      --set-default CODEX_PATH ${lib.getExe codex}
  '';

  doCheck = true;

  checkPhase = ''
    runHook preCheck
    npm test
    runHook postCheck
  '';

  postCheck = ''
    rm -r node_modules/.vite
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
})
