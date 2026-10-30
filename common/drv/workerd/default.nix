{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  versionCheckHook,
}:

let
  selectSystem =
    attrs:
    attrs.${stdenv.hostPlatform.system} or (throw "Unsupported system: ${stdenv.hostPlatform.system}");
  npmPlatform = selectSystem {
    x86_64-linux = "linux-64";
    aarch64-linux = "linux-arm64";
    aarch64-darwin = "darwin-arm64";
  };
  compatibilityDateOf =
    version:
    let
      date = lib.elemAt (lib.splitVersion version) 1;
    in
    "${lib.substring 0 4 date}-${lib.substring 4 2 date}-${lib.substring 6 2 date}";
in
stdenv.mkDerivation (finalAttrs: {
  pname = "workerd";
  version = "1.20261030.1";

  src = fetchurl {
    url = "https://registry.npmjs.org/@cloudflare/workerd-${npmPlatform}/-/workerd-${npmPlatform}-${finalAttrs.version}.tgz";
    hash = selectSystem {
      x86_64-linux = "sha256-fbEr9eHyCioNBiR8UwjwL14bS3sfo9zf9WLOVChHgSU=";
      aarch64-linux = "sha256-ud0iV4oM2Zbw12Fip7OB/ErY9pqAopgEPXrhzp937w4=";
      aarch64-darwin = "sha256-v8Acm3lpuxGzTKl5d5h05IFiQ57kSEa5Xh/9i70w0ug=";
    };
  };

  __structuredAttrs = true;
  strictDeps = true;

  nativeBuildInputs = lib.optionals stdenv.hostPlatform.isLinux [ autoPatchelfHook ];

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall
    install -Dm755 bin/workerd $out/bin/workerd
    runHook postInstall
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  preVersionCheck = ''
    version=${compatibilityDateOf finalAttrs.version}
  '';

  passthru.updateScript = ./update.sh;

  meta = {
    description = "JavaScript and WebAssembly runtime that powers Cloudflare Workers";
    homepage = "https://github.com/cloudflare/workerd";
    changelog = "https://github.com/cloudflare/workerd/releases/tag/v${finalAttrs.version}";
    downloadPage = "https://www.npmjs.com/package/workerd";
    license = lib.licenses.asl20;
    mainProgram = "workerd";
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
      "aarch64-darwin"
    ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
})
