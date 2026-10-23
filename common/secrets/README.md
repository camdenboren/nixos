# Secrets

One host-agnostic YAML file per service: `common/secrets/<service>.yaml`. This
implies some degree of duplication in the secrets files, though simplifies things for consuming services.

[sops-nix](https://github.com/Mic92/sops-nix#usage-example) decrypts the
selected YAML key into memory at `/run/secrets/<service>`. Environment-file
consumers use an `environment: |` block; other services use a named password
/token key. The [module](default.nix) sets ownership and service restarts.

## Setup

```sh
{
mkdir -p "~/.config/sops/age"
age-keygen -o "~/.config/sops/age/keys.txt"
}
```

If needed, copy this admin key from `media` to other machines:

```sh
{
mkdir -p ~/.config/sops/age
rsync -p -e ssh \
  media:.config/sops/age/keys.txt \
  /home/camdenboren/.config/sops/age/keys.txt
}
```

Then on each host (Linux or macOS), derive its recipient from the public SSH host key:

```sh
ssh-to-age < /etc/ssh/ssh_host_ed25519_key.pub
```

Keep private identities outside the repo and back them up.

## Edit the secrets files

Use SOPS to modify real secrets values privately:

```sh
sops common/secrets/vector.yaml
```

Repeat for every service, preserving each file's YAML keys, then build and switch.
The decryption identity persists across boots; decrypted service credentials
remain in memory.

fetch-rs, backup, and tailscale read changes on their next run; other consumers
restart automatically. After changing recipients, run `sops updatekeys <file>` and
commit the updated ciphertext.
