{ lib }:
let
  network = import ./network.nix;
  hosts = import ./hosts.nix;
  services = import ./services.nix;

  hostValues = builtins.attrValues hosts;
  proxmoxHosts = builtins.filter (host: host.provider == "proxmox") hostValues;
  vmids = builtins.map (host: host.vmid) proxmoxHosts;
  addresses = builtins.map (host: host.address) (builtins.filter (host: host ? address) hostValues);
  providersOk = lib.all (host: builtins.elem host.provider [ "proxmox" "linode" ]) hostValues;
  noHostVlan = lib.all (host: !(host ? vlan)) hostValues;
  unique = values: builtins.length values == builtins.length (lib.unique values);
in
assert lib.assertMsg (network.vlan == 600) "StarIntel infrastructure VLAN must remain 600";
assert lib.assertMsg providersOk "Every host provider must be proxmox or linode";
assert lib.assertMsg noHostVlan "Hosts may not override VLAN; inventory/network.nix owns VLAN 600";
assert lib.assertMsg (unique vmids) "Duplicate Proxmox VMID in inventory";
assert lib.assertMsg (unique addresses) "Duplicate host address in inventory";
{
  inherit network hosts services;
}
