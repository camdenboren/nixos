{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  makeWrapper,
  git,
  versionCheckHook,
}:

let
  sources = {
    x86_64-linux = {
      target = "x86_64-unknown-linux-gnu";
      hash = "sha256-yQFUV2y/3uv5T1u4NVJf3M0Xa3BnJJFDIM1hh+wYiOI=";
    };
    aarch64-linux = {
      target = "aarch64-unknown-linux-gnu";
      hash = "sha256-twTg+yv8wcRAq1kdA7Zrnw5ZaLDY3Am9YAK8h0yTMuY=";
    };
    aarch64-darwin = {
      target = "aarch64-apple-darwin";
      hash = "sha256-Xxaxfc9Gq7Vm7DOg9HM7RZwPvCKfzQ9YqeataY831Y4=";
    };
  };
  source =
    sources.${stdenv.hostPlatform.system}
      or (throw "xerj-bin: unsupported platform ${stdenv.hostPlatform.system}");
in
stdenv.mkDerivation (finalAttrs: {
  pname = "xerj-bin";
  version = "1.0.0-rc.104";

  src = fetchurl {
    url = "https://github.com/xerj-org/xerj/releases/download/v${finalAttrs.version}/xerj-${finalAttrs.version}-${source.target}.tar.gz";
    inherit (source) hash;
  };

  nativeBuildInputs = [
    makeWrapper
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [ autoPatchelfHook ];
  buildInputs = lib.optionals stdenv.hostPlatform.isLinux [ stdenv.cc.cc.lib ];

  dontConfigure = true;
  dontBuild = true;
  # preserve the upstream Mach-O signature and already-stripped release binaries
  dontStrip = true;

  installPhase = ''
    runHook preInstall
    install -Dm755 xerj "$out/bin/xerj"
    runHook postInstall
  '';

  postFixup = ''
    wrapProgram "$out/bin/xerj" --prefix PATH : ${lib.makeBinPath [ git ]}
  '';

  nativeInstallCheckInputs = [ versionCheckHook ];
  doInstallCheck = true;
  versionCheckProgram = "${placeholder "out"}/bin/xerj";
  versionCheckProgramArg = "--version";

  passthru.updateScript = ./update.sh;

  meta = {
    description = "Local-first search engine and MCP server for AI agents. One Rust binary indexes code, docs, logs, JSONL/CSV and PDFs for BM25 full-text, vector and hybrid search, code search without grep, agent memory and RAG. Elasticsearch-compatible API; Corpus Hub serves hundreds of reference memory corpora";
    homepage = "https://github.com/xerj-org/xerj";
    changelog = "https://github.com/xerj-org/xerj/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.asl20;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    mainProgram = "xerj";
    platforms = builtins.attrNames sources;
  };
})
