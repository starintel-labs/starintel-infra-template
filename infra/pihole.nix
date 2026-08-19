{ lib, inventory, ... }:
let
  dnsHosts = lib.filterAttrs (_: host: host ? dnsName && host ? address) inventory.hosts;
  stripPrefix = address: builtins.head (lib.splitString "/" address);
in
{
  resource.pihole_dns_record = lib.mapAttrs (_name: host: {
    domain = host.dnsName;
    ip = stripPrefix host.address;
  }) dnsHosts;
}
