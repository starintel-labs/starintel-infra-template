# Bootstrap before Hydra

NixOS nodes use Comin to pull `starintel-labs/starintel-infra` and deploy `nixosConfigurations.<hostname>` from `main`.

## Private repository credential

Until a dedicated credential service is wired in, each node needs a GitHub token with read-only access to the repository contents at:

```text
/var/lib/starintel/secrets/github-starintel-infra-read-token
```

The file must be owned by root and mode `0400`. The token is read at runtime and is never copied into the Nix store.

Comin is conditioned on that file existing, so a newly-created host remains stable before the bootstrap credential is installed.

## Deployment flow

```text
merge main
  -> Comin polls GitHub
  -> node evaluates nixosConfigurations.<hostname>
  -> node builds locally or substitutes from configured caches
  -> switch-to-configuration switch
```

When Hydra is available, keep this flow and add the Hydra cache/substituter. Comin can then pull the same commit while downloading pre-built closures instead of compiling them on every host.
