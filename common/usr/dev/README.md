# DevShells

Each language directory contains a standalone flake exporting
`devShells.${system}.default` through `pkgs.mkShell`. These are copyable project
templates; the repository's root flake does not export them as dev shells.

| Template                   | Packages                                     | Copy command |
| -------------------------- | -------------------------------------------- | ------------ |
| [c](c/flake.nix)           | GCC, GDB                                     | `dev -c`     |
| [java](java/flake.nix)     | JDK 25, Java language server                 | `dev -j`     |
| [python](python/flake.nix) | Python 3.14, Pyright, Ruff                   | `dev -p`     |
| [rust](rust/flake.nix)     | rustc, Cargo, rust-analyzer, rustfmt, Clippy | `dev -r`     |

All templates declare `x86_64-linux`, `aarch64-linux`, and `aarch64-darwin` outputs.
Actual package availability depends on the chosen platform and locked nixpkgs.
Each template uses `nixos-unstable`, a red Bash prompt, and a `shellHook` that prints
language-specific commands.

## Use in a project

```sh
cd ~/Documents/Repos/my-project
dev -r
# For a Git project, make the new flake visible to Nix:
git add flake.nix
nix develop
```

The [dev script](../scr/dev.nix) copies from `~/etc/nixos/common/usr/dev` into the
current directory. It overwrites an existing `flake.nix` without prompting; use
one language flag per invocation. Its destination is unquoted, so paths containing
spaces are unsupported by the current script.

Alternatively, enter a template directly from the repository root:

```sh
nix develop ./common/usr/dev/rust
```

Each flake resolves its own inputs; a copied template does not inherit the root
`flake.lock`. Keep the project's generated lockfile alongside its flake for
repeatable environments.

## Extend

Change `packages` for tools and `shellHook` for shell setup/help. To add a language,
copy a sibling template, adjust its packages and description, and add a matching
flag/path in `../scr/dev.nix`. Verify the chosen template with `nix develop` on the
intended platform.
