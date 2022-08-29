{ kor, pkgs, hyraizyn, konstynts, ... }:
let
  inherit (builtins) mapAttrs attrNames filter;
  inherit (kor) mkIf optionalString;
  inherit (hyraizyn.astra.spinyrz) izYggKriodaizd;
  inherit (konstynts) fileSystem;
  inherit (konstynts.fileSystem.yggdrasil) priKriadJson
    subDirName preKriomJson interfaceName combinedConfigJson;
  inherit (konstynts.network.yggdrasil) ports;

  package = pkgs.yggdrasil;
  yggExec = "${package}/bin/yggdrasil";
  yggCtlExec = "${package}/bin/yggdrasilctl";
  jqEksek = "${pkgs.jq}/bin/jq";

  yggKriodFilterSocket = fileSystem.systemd.runtimeDirectory + "/yggKriodFilter";

  mkConfigFile = conf: pkgs.writeTextFile {
    name = "yggdrasilConf.json";
    text = builtins.toJSON conf;
  };

  yggdrasilConfig = {
    IfName = "yggTun";
    NodeInfoPrivacy = true;
    MulticastInterfaces = [
      {
        Regex = ".*";
        Beacon = true;
        Listen = true;
        Port = ports.linkLocalTCP;
      }
    ];
  };

  configFile = mkConfigFile yggdrasilConfig;

  seedYggdrasil = !izYggKriodaizd;

  seedYggdrasilScript = pkgs.writeScript "createYggdrasilKeys.sh" ''
    if [[ ! -e ${priKriadJson} ]]; then
      ${yggExec} -genconf -json | \
        ${pkgs.jq}/bin/jq '{ PublicKey, PrivateKey }' > ${priKriadJson}
    fi
  '';

  extractPreKriomJson = ''
    ${yggCtlExec} -json -v getself > ${preKriomJson}
  '';

in
{
  environment.systemPackages = [ package ];

  networking.firewall = {
    allowedUDPPorts = [ ports.multicast ];
    allowedTCPPorts = [ ports.linkLocalTCP ];
    trustedInterfaces = [ interfaceName ];
  };

  systemd = {
    services = {
      yggdrasil = {
        description = "Yggdrasil Network Service";
        bindsTo = [ "network-online.target" ];
        after = [ "network-online.target" ];
        wantedBy = [ "multi-user.target" ];

        preStart = ''
          ${optionalString seedYggdrasil seedYggdrasilScript} 
          ${pkgs.jq}/bin/jq --slurp add ${priKriadJson} ${configFile} > ${combinedConfigJson}
        '';

        postStart = optionalString seedYggdrasil extractPreKriomJson;

        serviceConfig = {
          ExecStart = '' 
            ${yggExec} -useconffile ${combinedConfigJson}
          '';

          ExecReload = "${pkgs.coreutils}/bin/kill -HUP $MAINPID";
          Restart = "always";

          StateDirectory = subDirName;
          RuntimeDirectory = subDirName;
          RuntimeDirectoryMode = "0755";

          AmbientCapabilities = "CAP_NET_ADMIN";
          CapabilityBoundingSet = "CAP_NET_ADMIN";
          DynamicUser = true;
          MemoryDenyWriteExecute = true;
          ProtectControlGroups = true;
          ProtectHome = "tmpfs";
          ProtectKernelModules = true;
          ProtectKernelTunables = true;
          RestrictAddressFamilies = "AF_UNIX AF_INET AF_INET6 AF_NETLINK";
          RestrictNamespaces = true;
          RestrictRealtime = true;
          SystemCallArchitectures = "native";
          SystemCallFilter = "~@clock @cpu-emulation @debug @keyring @module @mount @obsolete @raw-io @resources";
        };
      };
    };

  };
}
