# Scripts

The `.nix` files accept `{ pkgs }` and return packages, usually via
`pkgs.writeShellScriptBin`. Hosts install them explicitly in
`hosts/<host>/usr/mod/pkgs/bin/scripts.nix` using:

```nix
home.packages = [
  (import ../../../../../../common/usr/scr/hello.nix { inherit pkgs; })
];
```

That relative path is from a host's `scripts.nix`. There is no automatic import
of every file in this directory.

| File                                     | Behavior and dependencies                                                                                                                                                                                                                                      |
| ---------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| [check.nix](check.nix)                   | Enters `$NH_FLAKE`, runs `statix check`, `deadnix -f` excluding hardware configurations, then `nix flake check`. Requires those commands on `PATH`; stops on failure.                                                                                          |
| [dev.nix](dev.nix)                       | Copies a [dev shell template](../dev/README.md) into the current directory with `-c`, `-j`, `-p`, or `-r`. Overwrites `flake.nix`; does not enter the shell.                                                                                                   |
| [findVPN.nix](findVPN.nix)               | Selects Sweden, simulates a fixed YouTube download, then retries random Mullvad countries until successful. Changes the active relay and has no retry limit. Embeds `boxes`/`yt-dlp` paths; needs `mullvad` and `tput` on `PATH` plus a working Mullvad setup. |
| [findVPNDesktop.nix](findVPNDesktop.nix) | Creates a terminal desktop launcher whose `Exec` is `findVPN`; install the script package alongside it.                                                                                                                                                        |
| [hello.nix](hello.nix)                   | Prints a greeting through `cowsay` and `lolcat`, both referenced by store path.                                                                                                                                                                                |
| [vulnxscan.py](vulnxscan.py)             | Reads `vulns.csv` from the working directory and prints Markdown counts and critical findings. Keeps only rows reported by multiple scanners (`row[8] > 1`); assumes the scanner's fixed CSV column order.                                                     |

All hosts install `check`, `dev`, and `hello`; `main` and `media` additionally install
the VPN script and launcher. The Python report is invoked by the `scan` alias in
[bash.nix](../mod/pkgs/bin/coding/bash.nix), after `vulnxscan` scans the current
host's flake output. It can also process an existing report from the repo root:

```sh
python3 common/usr/scr/vulnxscan.py
```

## Add a command

Follow `hello.nix`'s function/package structure, then add its import to each intended
host's `home.packages`. Reference dependencies as `${pkgs.<package>}/bin/<command>`
when they should travel with the script: `writeShellScriptBin` does not infer tools
from bare command names. Escape Bash `${...}` as `''${...}` inside Nix indented
strings. Keep simple interactive aliases/functions in `bash.nix`.
