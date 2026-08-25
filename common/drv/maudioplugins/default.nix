{
  fetchFromGitHub,
  fetchurl,
  innoextract,
  lib,
  python3,
  stdenvNoCC,
  zstd,
}:

let
  sourceMetadata = builtins.fromJSON (builtins.readFile ./sources.json);

  packageSource =
    name:
    let
      metadata = sourceMetadata.packages.${name};
    in
    fetchurl {
      url = "https://meldaproduction.b-cdn.net/download/${metadata.folder}/${name}_${metadata.version}.pkgm";
      inherit (metadata) hash;
    };

  packageSources = lib.mapAttrs (name: _: packageSource name) sourceMetadata.packages;

  managerSource = fetchurl {
    url = "https://meldaproduction.b-cdn.net/download/mpluginmanager/${sourceMetadata.manager.setupName}";
    inherit (sourceMetadata.manager) hash;
  };

  # Inno Setup 6.6 support is awaiting release upstream. MPluginManager uses
  # 6.6.1, so use the submitted support branch until innoextract releases it.
  innoextract66 = innoextract.overrideAttrs (_: {
    version = "1.9-unstable-pr210";
    src = fetchFromGitHub {
      owner = "dscho";
      repo = "innoextract";
      rev = "376a13e7c41cc5528b6088d0dd16ec1b323a8d37";
      hash = "sha256-i83tvVWHY8//8K2KPwkbbEStQ8ZnoOcoGCyrGoDWG+0=";
    };
  });

  freePlugins = [
    "MAGC"
    "MAnalyzer"
    "MAutoPitch"
    "MAutopan"
    "MBandPass"
    "MBitFun"
    "MCCGenerator"
    "MChannelMatrix"
    "MCharmVerb"
    "MComb"
    "MCompressor"
    "MConvolutionEZ"
    "MDelay"
    "MEqualizer"
    "MFlanger"
    "MFreeformPhase"
    "MFreqShifter"
    "MLoudnessAnalyzer"
    "MMetronome"
    "MNoiseGenerator"
    "MNotepad"
    "MOscillator"
    "MOscilloscope"
    "MPhaser"
    "MRatio"
    "MRatioMB"
    "MRecorder"
    "MRingModulator"
    "MSaturator"
    "MSpectralPan"
    "MStereoExpander"
    "MStereoScope"
    "MTremolo"
    "MTuner"
    "MUtility"
    "MVibrato"
    "MWaveFolder"
    "MWaveShaper"
  ];

  # These packages reproduce the shared ProgramData tree selected by a normal
  # MFreeFXBundle installation. The small *Devices packages contain hidden
  # .mfiles.mfs payloads that plain `tree` output does not show.
  completeDataPackages = [
    "GLOBAL"
    "GLOBAL_BYPLUGIN"
    "GLOBAL_BYPLUGINFOLDER_GLOBAL_MAutopanMB"
    "GLOBAL_BYPLUGINFOLDER_GLOBAL_MCombMB"
    "GLOBAL_BYPLUGINFOLDER_GLOBAL_MDelayMB"
    "GLOBAL_BYPLUGINFOLDER_GLOBAL_MFlangerMB"
    "GLOBAL_BYPLUGINFOLDER_GLOBAL_MFreqShifterMB"
    "GLOBAL_BYPLUGINFOLDER_GLOBAL_MMetronome"
    "GLOBAL_BYPLUGINFOLDER_GLOBAL_MPhaserMB"
    "GLOBAL_BYPLUGINFOLDER_GLOBAL_MRatioMB"
    "GLOBAL_BYPLUGINFOLDER_GLOBAL_MRingModulatorMB"
    "GLOBAL_BYPLUGINFOLDER_GLOBAL_MSaturatorMB"
    "GLOBAL_BYPLUGINFOLDER_GLOBAL_MTremoloMB"
    "GLOBAL_BYPLUGINFOLDER_GLOBAL_MVibratoMB"
    "GLOBAL_BYPLUGINFOLDER_GLOBAL_MWaveFolderMB"
    "GLOBAL_BYPLUGINFOLDER_GLOBAL_MWaveShaperMB"
    "GLOBAL_IR"
    "USER_MSOUNDFACTORY_OPTIONAL"
  ];

  exactStemArgs = lib.concatMap (name: [
    "--exact-stem"
    name
  ]) freePlugins;

  stemPrefixArgs = lib.concatMap (name: [
    "--stem-prefix"
    name
  ]) freePlugins;
in
stdenvNoCC.mkDerivation {
  pname = "maudioplugins";

  # Melda versions every component separately. Use the generic Windows kernel
  # version as the package version and keep all component versions in JSON.
  version = sourceMetadata.packages.BINEffects_binkernel.version;

  nativeBuildInputs = [
    innoextract66
    python3
    zstd
  ];

  dontUnpack = true;
  dontStrip = true;

  installPhase = ''
    runHook preInstall

    program_data="$out/share/maudioplugins/programdata/MeldaProduction"
    kernels="$out/share/maudioplugins/kernels"
    mkdir -p "$out/lib/winvst3" "$program_data"

    python3 ${./extract.py} \
      --flatten \
      --dll-as-vst3 \
      ${lib.escapeShellArgs exactStemArgs} \
      ${packageSources.BINEffects_binx64} \
      "$out/lib/winvst3"

    ${lib.concatMapStringsSep "\n" (name: ''
      python3 ${./extract.py} ${packageSources.${name}} "$program_data"
    '') completeDataPackages}

    # USER_PRESETS contains one plug-in-specific MLimiter file despite being a
    # global package. MLimiter is not part of MFreeFXBundle.
    python3 ${./extract.py} \
      --exclude MLimiter.presets \
      ${packageSources.USER_PRESETS} \
      "$program_data"

    # This package is explicitly item-detected by MPluginManager. Prefix
    # matching includes the free plug-ins' related processor preset files.
    python3 ${./extract.py} \
      ${lib.escapeShellArgs stemPrefixArgs} \
      ${packageSources.USER_PRESETS_BYPLUGIN} \
      "$program_data"

    python3 ${./extract.py} \
      ${packageSources.BINEffects_binkernel_avx2} \
      "$program_data/LIB"

    innoextract \
      --extract \
      --silent \
      --output-dir manager \
      ${managerSource}
    install -Dm755 \
      'manager/C$/ProgramData/MeldaProduction/LIB/MPluginManager.exe' \
      "$program_data/LIB/MPluginManager.exe"

    chmod +x "$out/lib/winvst3"/*.vst3 "$program_data/LIB"/*.dll

    runHook postInstall
  '';

  passthru = {
    updateScript = ./update.sh;
    programDataPath = "share/maudioplugins/programdata/MeldaProduction";
  };
}
