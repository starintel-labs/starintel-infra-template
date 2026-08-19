{
  description = "StarIntel infrastructure control plane";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-parts.inputs.nixpkgs-lib.follows = "nixpkgs";

    terranix.url = "github:terranix/terranix";
    terranix.inputs.nixpkgs.follows = "nixpkgs";

    comin.url = "github:nlewo/comin";
    comin.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ self, nixpkgs, flake-parts, terranix, comin, ... }:
    let
      lib = nixpkgs.lib;
      inventory = import ./inventory { inherit lib; };

      providerModule = host:
        if host.provider == "proxmox" then
          ./modules/proxmox-lxc.nix
        else if host.provider == "linode" then
          ./modules/linode.nix
        else
          throw "Unsupported host provider: ${host.provider}";

      mkHost = name: host:
        lib.nixosSystem {
          system = host.system or "x86_64-linux";
          specialArgs = { inherit inputs inventory host; };
          modules = [
            self.nixosModules.starintel-host
            (providerModule host)
            ./hosts/${name}/default.nix
            { networking.hostName = name; }
          ];
        };
    in
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [ terranix.flakeModule ];
      systems = [ "x86_64-linux" "aarch64-linux" ];

      perSystem = { config, pkgs, system, ... }: {
        terranix.terranixConfigurations.default = {
          terraformWrapper.package = pkgs.opentofu;
          workdir = ".state/infra";
          modules = [ ./infra ];
          extraArgs = { inherit inventory; };
        };

        checks = {
          inventory = pkgs.writeText "starintel-inventory-${system}.json" (builtins.toJSON inventory);
          infra = config.terranix.terranixConfigurations.default.result.terraformConfiguration;
        };

        formatter = pkgs.nixfmt;
      };

      flake = {
        nixosModules.starintel-host = {
          imports = [
            comin.nixosModules.comin
            ./modules/base.nix
            ./modules/cd-pull.nix
            ./modules/ingress.nix
            ./modules/secrets.nix
          ];
        };

        nixosConfigurations = lib.mapAttrs mkHost inventory.hosts;
      };
    };
}
