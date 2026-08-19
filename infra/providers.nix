{ ... }:
{
  terraform.required_version = ">= 1.6.0";
  terraform.required_providers = {
    proxmox = {
      source = "bpg/proxmox";
      version = "~> 0.107";
    };
    pihole = {
      source = "lukaspustina/pihole";
    };
    linode = {
      source = "linode/linode";
      version = "~> 4.3";
    };
  };
}
