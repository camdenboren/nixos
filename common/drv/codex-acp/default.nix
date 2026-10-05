{
  lib,
  buildNpmPackage,
  codex,
  fetchFromGitHub,
  makeBinaryWrapper,
  stdenv,
  versionCheckHook,
}:

let
  disabledDarwinTests = [
    "should throw error without authentication"
    "should authenticate with key"
    "should authenticate with CODEX_API_KEY from the environment"
    "should fall back to OPENAI_API_KEY from the environment"
    "should authenticate with a gateway"
    "should show account in /status for api key auth and hide it for gateway auth"
    "should fail on wrong sessionId"
    "handles logout command"
    "handles skills command"
    "handles mcp command"
    "handles builtin slash command locally when prompt has attachments"
    "should preserve the global url-based MCP when ACP passes a command-type MCP with the same name"
    "should preserve a project url-based MCP when ACP passes a command-type MCP with the same name"
    "should not filter the conflicting ACP MCP when config filtering is disabled"
    "should return configured mcp"
  ];
  testFlags = lib.optionals stdenv.hostPlatform.isDarwin [
    "--testNamePattern"
    "^(?!.*(?:${lib.concatStringsSep "|" disabledDarwinTests})$).*"
  ];
in
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
    npm test -- ${lib.escapeShellArgs testFlags}
    runHook postCheck
  '';

  postCheck = ''
    rm -r node_modules/.vite
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
})
