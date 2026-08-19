{ lib, ... }:
{
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    auto-optimise-store = true;
  };

  services.openssh.enable = true;
  system.stateVersion = lib.mkDefault "26.05";
}
