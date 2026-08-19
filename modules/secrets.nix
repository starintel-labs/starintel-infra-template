{ ... }:
{
  # Secret material is intentionally not declared inline. Bootstrap credentials
  # are installed under /var/lib/starintel/secrets and will later move to the
  # chosen encrypted-secret workflow without entering /nix/store.
  systemd.tmpfiles.rules = [
    "d /var/lib/starintel 0750 root root -"
    "d /var/lib/starintel/secrets 0700 root root -"
  ];
}
