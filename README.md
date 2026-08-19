# starintel-infra

Declarative infrastructure and NixOS configuration for StarIntel.

## Contract

- `main` is the desired state.
- Managed Proxmox containers are always attached to VLAN 600.
- NixOS nodes pull this private repository with Comin and deploy their own `nixosConfigurations.<hostname>`.
- OpenTofu/Terranix owns infrastructure lifecycle: Proxmox, Pi-hole DNS, and Linode.
- Caddy owns HTTP ingress on edge hosts.
- Secrets are never committed to the Nix store or repository.
- Hydra will later become the build/cache producer without changing the pull-based deployment model.

## Commands

```sh
nix flake check
nix run .#default.plan
nix run .#default
```

`default.plan` plans the Terranix/OpenTofu configuration in `.state/infra`; `default` applies it.

## Adding a host

1. Add the host to `inventory/hosts.nix`.
2. Add `hosts/<hostname>/default.nix`.
3. For a private-repo Comin node, install a read-only GitHub token at `/var/lib/starintel/secrets/github-starintel-infra-read-token`.
4. Merge to `main`. The node polls `main` and switches itself.

See `docs/bootstrap.md` for the initial secret/bootstrap path.
