# Overlays

[default.nix](default.nix) imports Nix modules that append functions to
`nixpkgs.overlays`. Both the common system and Home Manager environment modules
import this directory, so their package sets receive the same customizations.

| Module                                   | Exposes or changes                                                                                                                     |
| ---------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------- |
| [agents.nix](agents.nix)                 | Local `kiwix-mcp`, `pi-acp`, `pi-mcp-adapter`, `pi-sandbox`, and `xerj-bin` packages. Enables Kiwix's certificate patch when `hostname != "media"`. |
| [firefox-addons.nix](firefox-addons.nix) | `pkgs.firefox-addons` from the flake input, extended with `vimium-new-tab-page`; supplies the input's `buildFirefoxXpiAddon` helper.   |
| [homelab.nix](homelab.nix)               | Local `actual-cli`, `drawio`, and `outline-export` packages, none in nixpkgs.                                                          |
| [icons.nix](icons.nix)                   | Overrides Dracula's `postInstall` to replace application/VPN icons and `index.theme`; several filenames depend on `rice`.              |
| [personal.nix](personal.nix)             | `alc-calc` and `yt-x` from their inputs' `packages.${system}.default`.                                                                 |
| [plugins.nix](plugins.nix)               | Audio packages and `dxvk-bin` from [../drv](../drv/README.md).                                                                         |

The host definitions provide `inputs`, `system`, `hostname`, and `rice` through
system `specialArgs` and Home Manager `extraSpecialArgs`.

## Extend an overlay

Add an attribute to the appropriate existing overlay:

```nix
_final: prev: {
  example = prev.callPackage ../drv/example { };
}
```

`prev` supplies the package set before this overlay. For an existing package,
use `prev.<name>.overrideAttrs` and preserve existing hooks, as `icons.nix` does
with `(o.postInstall or "") + ...`. A new overlay module must also appear in
`default.nix`'s imports.

Adding an overlay attribute makes it available as `pkgs.example`; install or use
it explicitly in a host module. From the repository root, inspect an existing
attribute with:

```sh
nix eval --raw .#nixosConfigurations.main.pkgs.nova.version
```

For a new rice, provide each corresponding icon asset under `common/usr/rice/icons`
and keep the host's `rice` argument aligned with the Home Manager option.
