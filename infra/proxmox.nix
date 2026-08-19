{ lib, inventory, ... }:
let
  hosts = lib.filterAttrs (_: host: host.provider == "proxmox") inventory.hosts;

  mkContainer = name: host: {
    description = "Managed by starintel-infra";
    node_name = host.node;
    vm_id = host.vmid;
    start_on_boot = true;
    unprivileged = true;

    cpu = [
      { cores = host.cores or 2; }
    ];

    memory = [
      { dedicated = host.memory or 2048; }
    ];

    disk = [
      {
        datastore_id = host.storage or "local-lvm";
        size = host.disk or 16;
      }
    ];

    operating_system = [
      {
        type = "nixos";
        template_file_id = host.templateFileId;
      }
    ];

    initialization = [
      {
        hostname = name;
        ip_config = [
          {
            ipv4 = [
              {
                address = host.address;
                gateway = host.gateway or inventory.network.gateway;
              }
            ];
          }
        ];
      }
    ];

    network_interface = [
      {
        name = "eth0";
        bridge = host.bridge or inventory.network.bridge;
        vlan_id = inventory.network.vlan;
      }
    ];

    tags = [ "starintel" "nixos" "vlan-600" ];
  };
in
{
  resource.proxmox_virtual_environment_container = lib.mapAttrs mkContainer hosts;
}
