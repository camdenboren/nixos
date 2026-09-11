# Derivations

Each `<package>/default.nix` is a function returning a package. The modules in
[../ovy](../ovy/README.md) expose these through `pkgs` using `callPackage`;
installing a package still requires a host package list or service reference.

## Package layout

| Area           | Implementation                                                                                                                                                                                      |
| -------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Linux audio    | `audiogridder` installs into `lib/vst`, `loudmax` into `lib/ladspa`, and `neural-amp-modeler-lv2` builds with CMake into `lib/lv2`. `sitala` unpacks a Debian package and patches ELF dependencies. |
| Windows audio  | Most remaining audio packages extract binaries into `lib/winvst3` for Wine/yabridge. This directory also holds Abstract Vox's DLL and instrument data.                                              |
| Melda          | `maudioplugins` reads component versions/hashes from `sources.json`; `extract.py` extracts selected free plugins and shared ProgramData.                                                            |
| Wine graphics  | `dxvk-bin` preserves the upstream `x32`/`x64` DLL layout.                                                                                                                                           |
| Homelab        | `drawio` builds static web assets with Ant/JDK and embeds `https://draw.home.local` in its preconfiguration.                                                                                        |
| Agent adapters | `codex-acp`, `pi-acp`, and `pi-mcp-adapter` use `buildNpmPackage`; `kiwix-mcp` uses `buildPythonApplication`.                                                                                       |
| Browser        | `vimium-new-tab-page` requires `buildFirefoxXpiAddon`, supplied by the Firefox overlay.                                                                                                             |

Windows plugins are connected to the Wine prefix by
[installPlugins.nix](../../hosts/main/usr/scr/installPlugins.nix), including
Melda's ProgramData and DXVK. Extracting a package alone does not perform that setup.
Binary archives have platform constraints even where package metadata is permissive.

## Build and update

From the repository root, build through a host's overlaid, flake-pinned package set:

```sh
nix build .#nixosConfigurations.main.pkgs.nova
```

Use an appropriate builder for the host platform. The `bld` shell alias also builds
`default.nix` in the current directory, but uses `<nixpkgs>` instead of the flake's
package set and does not supply overlay-specific arguments.

For custom package updates, use the `updatePkg` Bash function from
[bash.nix](../usr/mod/pkgs/bin/coding/bash.nix), also from the repository root:

```sh
updatePkg nova
# Equivalent to:
nix-update nixosConfigurations.main.pkgs.nova --flake
```

Pass the package's overlay attribute name. The function always targets `main`'s
package set, regardless of the current host, and delegates the update to
`nix-update`. Review the resulting diff and build the package afterward.

- Update `version`, the source URL/revision, and the matching source hash together.
  npm packages also carry `npmDepsHash`; `pi-mcp-adapter` repairs its lockfile before
  dependency fetching and reuses that repaired lockfile during the build.
- Packages with `passthru.updateScript` use either a local `update.sh` or shared
  `updateScriptAO.sh` / `updateScriptTDR.sh` with arguments declared in the derivation.
  Run these from within the checkout. For example:

  ```sh
  ./common/drv/updateScriptTDR.sh tdr-nova Nova nova/default.nix
  ./common/drv/maudioplugins/update.sh
  ```

- Review updater changes and build the affected package. Melda's updater modifies
  `sources.json`; its package version comes from the generic Windows kernel entry.

To add a package, create its derivation, expose it in the relevant overlay, then
reference `pkgs.<name>` in the consuming module. Keep extraction paths aligned with
the consumer, especially `lib/winvst3` and Melda's shared data path.
