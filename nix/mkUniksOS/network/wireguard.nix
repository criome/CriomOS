{ kor, pkgs, hyraizyn, konstynts, ... }:
let
  inherit (builtins) mapAttrs attrNames filter;
  inherit (kor) mkIf;
  inherit (hyraizyn.astra.spinyrz) izWireguardKriadyd wireguard;

  untrustedProxies =
    map mkUntrustedProxy wireguard.untrustedProxies;

  mkUntrustedProxy = untrustedProxy:
    {
      allowedIPs = [ ];
      publicKey = "";
      endpoint = "";
    };

in
{
  networking = {
    wireguard = {
      enable = true;
      interfaces = {
        wg0 = {
          ips = [ ];
          privateKey = "";
          peers = untrustedProxies;
        };
      };
    };
  };

}
