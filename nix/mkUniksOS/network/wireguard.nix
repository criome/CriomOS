{ kor, pkgs, hyraizyn, konstynts, ... }:
let
  inherit (builtins) mapAttrs attrNames filter;
  inherit (kor) mkIf mapAttrsToList;
  inherit (hyraizyn) exAstriz;
  inherit (hyraizyn.astra.spinyrz) hazWireguardPriKriom wireguard;

  untrustedProxies =
    map mkUntrustedProxy wireguard.untrustedProxies;

  mkUntrustedProxy = untrustedProxy: {
    allowedIPs = [ ];
    publicKey = "";
    endpoint = "";
  };

  mkNeksysPeer = neim: astri: {
    allowedIPs = [ ];
    publicKey = "";
    endpoint = "";
  };

  neksysPeers = mapAttrsToList mkNeksysPeer exAstriz;

in
{
  networking = {
    wireguard = {
      enable = true;
      interfaces = {
        wg0 = {
          ips = [ ];
          privateKeyFile = "";
          peers = neksysPeers ++ untrustedProxies;
        };
      };
    };
  };

}
