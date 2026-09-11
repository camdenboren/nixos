# Homelab

[default.nix](default.nix) imports each service module plus shared system utilities.
Most applications use native NixOS services; Penpot uses Podman containers and
draw.io is served directly from `pkgs.drawio`.

## Routing

[nginx.nix](nginx.nix) maps `home.local` to Homepage and application subdomains to
backends. Unless specified below, backend addresses are `127.0.0.1` on `media`.
Ports here describe the configured proxy targets; several services use module
defaults, so keep those defaults aligned with this table when changing inputs.

| Host under `home.local` | Backend                                             | Configuration                                                                                |
| ----------------------- | --------------------------------------------------- | -------------------------------------------------------------------------------------------- |
| Base domain             | Homepage `:8082`                                    | [homepage.nix](homepage.nix)                                                                 |
| `chat`                  | Open WebUI `:8080`                                  | [open-webui.nix](open-webui.nix); Ollama on media and `192.168.1.88:11434`                   |
| `media`                 | Jellyfin `:8096`                                    | [jellyfin.nix](jellyfin.nix)                                                                 |
| `photos`                | Immich `:2283`                                      | [immich.nix](immich.nix)                                                                     |
| `archive`               | Kiwix `:9095`                                       | [kiwix.nix](kiwix.nix)                                                                       |
| `notes`, `dex`          | Outline `:3000`, Dex `:5556`                        | [outline.nix](outline.nix); OIDC login                                                       |
| `design`                | Penpot frontend `:9001`                             | [penpot.nix](penpot.nix)                                                                     |
| `draw`                  | Static `pkgs.drawio`                                | `nginx.nix`; the declared `9040` port is unused                                              |
| `pdf`                   | BentoPDF-managed Nginx vhost                        | [bentopdf.nix](bentopdf.nix); separate from `nginx.nix`'s domain map                         |
| `box`, `car`, `money`   | Homebox `:7745`, LubeLogger `:5000`, Actual `:4000` | [homebox.nix](homebox.nix), [lubelogger.nix](lubelogger.nix), [actual.nix](actual.nix)       |
| `ntfy`                  | ntfy `:2586`                                        | [ntfy-sh.nix](ntfy-sh.nix)                                                                   |
| `sync`                  | Syncthing `:8384`                                   | [Shared Home Manager service](../../../../../../common/usr/mod/pkgs/srv/utils/syncthing.nix) |
| `torrent`               | qBittorrent `:9080`                                 | Proxy expects its Web UI here; no matching port configuration is declared in this directory  |
| `image`                 | `192.168.1.88:9090`                                 | Remote backend on `main`                                                                     |
| `util`                  | `192.168.1.93:8080`                                 | Remote backend on `mac`, with Nginx basic auth                                               |

`kiwix.nix` also starts a separate `kiwix-mcp` systemd service using streamable HTTP and `KIWIX_BASE_URL=http://localhost:9095`.

## DNS, TLS, and runtime files

- [unbound.nix](unbound.nix) resolves the `home.local` zone to `100.99.5.32` on the
  Tailscale interface, after `tailscaled-autoconnect.service`. Tailnet clients must
  use this resolver for the zone; client DNS setup is outside this directory.
- [Shared networking](../../../../../../common/sys/mod/cfg/hw/networking.nix)
  maps local hosts to `192.168.1.78` (loopback on media), opens HTTP/HTTPS on media
  and DNS on its Tailscale interface, and installs `home-local.pem` in Linux trust.
  Its comments describe manual macOS Keychain trust.
- Nginx requests the base certificate through `security.acme` and reuses it for
  most subdomains; BentoPDF enables ACME for its own vhost. The config also relies
  on a checked-in local certificate. Certificate issuance/provisioning is not
  fully described here; keep the served certificate and client trust aligned.
- Runtime secret paths are `/var/lib/secrets/tailscale`, `/var/lib/secrets/dex`,
  `/var/lib/secrets/homebox`, and `/var/lib/secrets/penpot`. Provision them for their
  consumers; the Penpot file supplies container environment variables. Outline
  reuses Dex's client secret and currently disables Node TLS verification.
- Immich stores media at `/mnt/media/Pictures`. Kiwix reads
  `/mnt/media/Archives/library.xml`; add archives with `kiwix-manage library.xml add
file.zim` from that directory. Penpot persists assets and PostgreSQL data in
  `penpot_penpot_assets` and `penpot_penpot_postgres_v15` Podman volumes.
