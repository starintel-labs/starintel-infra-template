{ config, lib, ... }:
let
  cfg = config.starintel.ingress;
  routeType = lib.types.submodule {
    options = {
      upstream = lib.mkOption {
        type = lib.types.str;
        description = "Caddy reverse_proxy upstream, for example 10.60.0.20:8080.";
      };
    };
  };
in
{
  options.starintel.ingress.routes = lib.mkOption {
    type = lib.types.attrsOf routeType;
    default = { };
    description = "Map of public DNS name to reverse proxy upstream.";
  };

  config = lib.mkIf (cfg.routes != { }) {
    services.caddy.enable = true;
    services.caddy.virtualHosts = lib.mapAttrs (_domain: route: {
      extraConfig = ''
        reverse_proxy ${route.upstream}
      '';
    }) cfg.routes;
  };
}
