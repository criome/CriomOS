{ kor, pkgs, hyraizyn, konstynts, ... }:
let
  inherit (builtins) mapAttrs attrNames filter;
  inherit (kor) mkIf mapAttrsToList;
  inherit (hyraizyn) exAstriz;
  inherit (hyraizyn.astra.spinyrz) hazWireguardPriKriom
    wireguardUntrustedProxies;

  mkUntrustedProxy = untrustedProxy: {
    allowedIPs = [ ];
    publicKey = "";
    endpoint = "";
  };

  untrustedProxies = map mkUntrustedProxy wireguardUntrustedProxies;

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
