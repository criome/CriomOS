{ kor, lib, hyraizyn, ... }:
let
  inherit (lib) mkOverride optional;
  inherit (kor) concatMapAttrs;
  inherit (hyraizyn) astra exAstriz;
  inherit (builtins) concatStringsSep;

  mkUniksHostEntry = neim: astri:
    let
      inherit (astri) uniksNeim neksysIp;
      mkPriNeksysHost = linkLocalIP: {
        name = linkLocalIP;
        value = [ (concatStringsSep "." [ "wg" astri.neim ]) ];
      };

    in
    (optional (neksysIp != null) {
      name = neksysIp;
      value = [ uniksNeim ];
    }) ++ (map mkPriNeksysHost astri.linkLocalIPs);

  uniksHosts = concatMapAttrs mkUniksHostEntry exAstriz;

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
