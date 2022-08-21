{ kor, lib, hyraizyn, ... }:
let
  inherit (lib) mkOverride optional;
  inherit (kor) concatMapAttrs;
  inherit (hyraizyn) astra exAstriz;
  inherit (builtins) concatStringsSep;

  mkNiksHostEntry = neim: astri:
    let
      inherit (astri) krioniksNeim neksysIp;
      mkPriNeksysHost = linkLocalIP: {
        name = linkLocalIP;
        value = [ (concatStringsSep "." [ "wg" krioniksNeim ]) ];
      };

    in
    (optional (neksysIp != null) {
      name = neksysIp;
      value = [ krioniksNeim ];
    }) ++ (map mkPriNeksysHost astri.linkLocalIPs);

  niksHosts = concatMapAttrs mkNiksHostEntry exAstriz;

in
{
  imports = [
    ./unbound.nix
    ./yggdrasil.nix
  ];

  networking = {
    hostName = astra.neim;
    dhcpcd.extraConfig = "noipv4ll";
    nameservers = [ "::1" ];
    hosts = niksHosts;
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
