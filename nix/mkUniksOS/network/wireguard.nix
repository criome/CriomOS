{ kor, pkgs, hyraizyn, konstynts, ... }:
let
  inherit (builtins) mapAttrs attrNames filter;
  inherit (kor) mkIf;
  inherit (hyraizyn) exAstriz;
  inherit (hyraizyn.astra.spinyrz) hazWireguardPriKriom wireguard;

  untrustedProxies =
    map mkUntrustedProxy wireguard.untrustedProxies;

  mkUntrustedProxy = untrustedProxy:
    {
      allowedIPs = [ ];
      publicKey = "";
      endpoint = "";
    };

  neksysPeers = map mkNeksysPeer exAstriz;

in
{
  networking = {
    wireguard = {
      enable = true;
      interfaces = {
        wg0 = {
          ips = [ ];
          privateKey = "";
          peers = neksysPeers ++ untrustedProxies;
        };
      };
    };
  };

}
