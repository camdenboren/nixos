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
  version = "1.6.2";

  src = fetchFromGitHub {
    owner = "agentclientprotocol";
    repo = "codex-acp";
    tag = "v${finalAttrs.version}";
    hash = "sha256-QNQ9x4CEO6xzKDd1vggBbntnGLjI1TBmg5ydCWM3T7k=";
  };

  npmDepsHash = "sha256-uK03isdvl9tpYDF1sapHjmPdhtLGbdjE3cDU/qFa5G0=";

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
