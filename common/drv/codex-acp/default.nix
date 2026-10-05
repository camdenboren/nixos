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
  version = "2.1.1";

  src = fetchFromGitHub {
    owner = "agentclientprotocol";
    repo = "codex-acp";
    tag = "v${finalAttrs.version}";
    hash = "sha256-bSxt9vtFnIrdZDmFJdYAfqkgm4BrGYKe420RamPkZvg=";
  };

  npmDepsHash = "sha256-7v7QE0cmYsd3JGu0VoT53yZ1rb9wYB+tXt05G1EEvz8=";

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
