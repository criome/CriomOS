{ lib, hyraizyn, config, ... }:
let
  l = lib // builtins;
  inherit (hyraizyn.astra) typeIs;

  wanInterface = "enp0s20u2";
  lanInterfaceOne = "enp0s25";
  lanInterfaceTwo = "enp0s26u1u2";
  lanBridgeInterface = "br-lan";
  lanSubnetPrefix = "10.18.0";
  lanAddress = "${lanSubnetPrefix}.1";
  lanFullAdress = "${lanAddress}/24";

in
{
  networking = {
    useNetworkd = true;
    useDHCP = false;

    nat.enable = false;
    firewall.enable = false;

    nftables = {
      enable = true;
      ruleset = ''
        table inet filter {
          chain input {
            type filter hook input priority 0; policy drop;

            iifname { ${lanBridgeInterface} } accept comment "Allow local network to access the router"
            iifname "${wanInterface}" ct state { established, related } accept comment "Allow established traffic"
            iifname "${wanInterface}" icmp type { echo-request, destination-unreachable, time-exceeded } counter accept comment "Allow select ICMP"
            iifname "${wanInterface}" counter drop comment "Drop all other unsolicited traffic from ${wanInterface}"
            iifname "lo" accept comment "Accept everything from loopback interface"
          }
          chain forward {
            type filter hook forward priority filter; policy drop;

            iifname { ${lanBridgeInterface} } oifname { "${wanInterface}" } accept comment "Allow trusted LAN to WAN"
            iifname { "${wanInterface}" } oifname { ${lanBridgeInterface} } ct state { established, related } accept comment "Allow established back to LANs"
          }
        }

        table ip nat {
          chain postrouting {
            type nat hook postrouting priority 100; policy accept;
            oifname "${wanInterface}" masquerade
          }
        }
      '';
    };
  };

  services = {
    kea = {
      dhcp4 = {
        enable = true;
        settings = {
          valid-lifetime = 4000;
          renew-timer = 1000;
          rebind-timer = 2000;
          interfaces-config = {
            interfaces = [ lanBridgeInterface ];
          };
          lease-database = {
            type = "memfile";
            persist = true;
            name = "/var/lib/kea/dhcp4.leases";
          };
          subnet4 = [{
            subnet = lanFullAdress;
            pools = [{ pool = "${lanSubnetPrefix}.100 - ${lanSubnetPrefix}.240"; }];
            option-data = [{ name = "routers"; data = lanAddress; }];
          }];
        };
      };
    };
  };

  systemd.network = {
    wait-online.anyInterface = true;

    netdevs = {
      "20-br-lan" = {
        netdevConfig = {
          Kind = "bridge";
          Name = lanBridgeInterface;
        };
      };
    };

    networks = {
      "30-lan0" = {
        matchConfig.Name = lanInterfaceOne;
        networkConfig = {
          Bridge = lanBridgeInterface;
          ConfigureWithoutCarrier = true;
        };
        linkConfig.RequiredForOnline = "enslaved";
      };

      "30-lan3" = {
        matchConfig.Name = lanInterfaceTwo;
        networkConfig = {
          Bridge = lanBridgeInterface;
          ConfigureWithoutCarrier = true;
        };
        linkConfig.RequiredForOnline = "enslaved";
      };

      "40-br-lan" = {
        matchConfig.Name = lanBridgeInterface;
        bridgeConfig = { };
        address = [ lanFullAdress ];
        networkConfig = {
          ConfigureWithoutCarrier = true;
        };
      };

      "10-wan" = {
        matchConfig.Name = "${wanInterface}";
        networkConfig = {
          # start a DHCP Client for IPv4 Addressing/Routing
          DHCP = "ipv4";
          DNSOverTLS = true;
          DNSSEC = true;
          IPv6PrivacyExtensions = false;
          IPForward = true;
        };
        # make routing on this interface a dependency for network-online.target
        linkConfig.RequiredForOnline = "routable";
      };
    };
  };
}
