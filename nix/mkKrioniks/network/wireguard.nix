{ kor, pkgs, hyraizyn, konstynts, pkdjz, ... }:
let
  inherit (builtins) mapAttrs attrNames filter concatStringsSep;
  inherit (kor) mkIf mapAttrsToList optionalAttrs filterAttrs;
  inherit (hyraizyn) astra exAstriz;
  inherit (hyraizyn.astra.spinyrz) hazWireguardPriKriom
    wireguardUntrustedProxies;

  mkUntrustedProxy = untrustedProxy: {
    inherit (wireguardUntrustedProxies) publicKey endpoint;
    allowedIPs = [ "0.0.0.0/0" ];
  };

  mkUntrustedProxyIp = untrustedProxy: untrustedProxy.interfaceIp;

  untrustedProxiesPeers = map mkUntrustedProxy wireguardUntrustedProxies;

  untrustedProxiesIps = map mkUntrustedProxyIp wireguardUntrustedProxies;

  mkNeksysPeer = neim: astri: {
    allowedIPs = [ astri.neksysIp ];
    publicKey = astri.wireguardPriKriom;
    endpoint = "wg.${astri.krioniksNeim}:51820";
  };

  kriomaizdPriNeksiz = filterAttrs (n: v: v.spinyrz.hazWireguardPriKriom)
    exAstriz;

  neksysPeers = mapAttrsToList mkNeksysPeer kriomaizdPriNeksiz;

  privateKeyFile = "/etc/wireguard/privateKey";

in
{
  networking = {
    wireguard = {
      enable = true;
      interfaces = {
        wgProxies = {
          ips = untrustedProxiesIps;
          peers = untrustedProxiesPeers;
          inherit privateKeyFile;
        };

        wgNeksys = {
          ips = [ astra.neksysIp ];
          inherit privateKeyFile;
          peers = neksysPeers;
          listenPort = 51820;
        };

      };
    };
  };

}
