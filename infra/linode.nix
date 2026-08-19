{ lib, inventory, ... }:
let
  hosts = lib.filterAttrs (_: host: host.provider == "linode") inventory.hosts;

  mkInstance = name: host: {
    label = name;
    region = host.region;
    type = host.type;
    image = host.image;
    authorized_keys = host.authorizedKeys;
    tags = [ "starintel" "nixos" "edge" ];
  };
in
{
  resource.linode_instance = lib.mapAttrs mkInstance hosts;
}
