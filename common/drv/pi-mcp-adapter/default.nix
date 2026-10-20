{
  lib,
  buildNpmPackage,
  fetchNpmDeps,
  fetchFromGitHub,
  npm-lockfile-fix,
}:

buildNpmPackage rec {
  pname = "pi-mcp-adapter";
  version = "5.3.2";
  src = fetchFromGitHub {
    owner = "nicobailon";
    repo = "pi-mcp-adapter";
    tag = "v${version}";
    hash = "sha256-syx9/d3IGyTExenHwwaVFuFN5jZvM8gVn8/+W8bJ8jk=";
  };

  npmDepsHash = "sha256-z15eeQQYtuLrCjMXI82GDM/VCqZXEKF8Rm6brT7mPM0=";
  npmDepsFetcherVersion = 2;
  npmDeps = fetchNpmDeps {
    inherit src;
    hash = npmDepsHash;
    fetcherVersion = npmDepsFetcherVersion;
    postPatch = ''
      ${lib.getExe npm-lockfile-fix} package-lock.json
    '';
  };

  postPatch = ''
    cp ${npmDeps}/package-lock.json package-lock.json
  '';
  npmBuildScript = "build:public";

  meta = {
    description = "Token-efficient MCP adapter for Pi coding agent";
    homepage = "https://github.com/nicobailon/pi-mcp-adapter";
    changelog = "https://github.com/nicobailon/pi-mcp-adapter/blob/${src.rev}/CHANGELOG.md";
    license = lib.licenses.mit;
    mainProgram = "pi-mcp-adapter";
    platforms = lib.platforms.all;
  };
}
