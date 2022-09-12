{ kor, lib, hyraizyn, ... }:
let
  inherit (kor) concatMapAttrs;
  inherit (lib) mkOverride optional optionals;
  inherit (hyraizyn) astra exAstriz;
  inherit (builtins) concatStringsSep;

  mkKriomHostEntries = neim: astri:
    let
      inherit (astri) krioniksNeim neksysIp yggAddress;
      inherit (astri.spinyrz) izNiksKac nixCacheUrl;

      mkPreNeksysHost = linkLocalIP: {
        name = linkLocalIP;
        value = [ ("wg." + krioniksNeim) ];
      };

      neksysHost = {
        name = neksysIp;
        value = [ krioniksNeim ];
      };

      preNeksysHosts = map mkPreNeksysHost astri.linkLocalIPs;

      neksysHosts = optionals (neksysIp != null)
        ([ neksysHost ] ++ preNeksysHosts);

      yggdrasilHost = optional (yggAddress != null) {
        name = yggAddress;
        value = [ krioniksNeim ] ++
          (optional izNiksKac nixCacheUrl);
      };

    in
    yggdrasilHost ++ neksysHosts;

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
    hosts = concatMapAttrs mkKriomHostEntries exAstriz;
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
