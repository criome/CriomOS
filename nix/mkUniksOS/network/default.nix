{ kor, lib, hyraizyn, ... }:
let
  inherit (lib) mkOverride optional;
  inherit (kor) mapAttrs';
  inherit (hyraizyn) astra exAstriz;
  inherit (builtins) concatStringsSep;

  mkUniksHostEntry = neim: astri:
    let
      inherit (astri) uniksNeim neksysIp;
    in
    {
      name = uniksNeim;
      value = optional (neksysIp != null) neksysIp;
    };

  uniksHosts = mapAttrs' mkUniksHostEntry exAstriz;

in
{
  imports = [
    ./unbound.nix
    ./wireguard.nix
  ];

  networking = {
    hostName = astra.neim;
    dhcpcd.extraConfig = "noipv4ll";
    nameservers = [ "::1" ];
    hosts = uniksHosts;
  };

  services = {
    nscd.enable = false;
  };

  system.nssModules = mkOverride 0 [ ];

  systemd = {
    targets = {
      neksys = {
        description = "neksys network online";
        after = [ "network-online.target" ];
        wantedBy = [ "multi-user.target" ];
      };
    };

  };
}
