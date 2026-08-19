{ lib, ... }:
let
  tokenPath = "/var/lib/starintel/secrets/github-starintel-infra-read-token";
in
{
  services.comin = {
    enable = true;
    remotes = [
      {
        name = "starintel-infra";
        url = "https://github.com/starintel-labs/starintel-infra.git";
        auth = {
          username = "comin";
          access_token_path = tokenPath;
        };
        branches.main = {
          name = "main";
          operation = "switch";
        };
        poller.period = 60;
      }
    ];
  };

  # The initial bootstrap installs the read-only token out of band. Do not make
  # a missing token flap the service forever on a freshly-created container.
  systemd.services.comin.unitConfig.ConditionPathExists = tokenPath;

  assertions = [
    {
      assertion = lib.hasPrefix "/var/lib/starintel/secrets/" tokenPath;
      message = "Comin credentials must live outside the Nix store";
    }
  ];
}
