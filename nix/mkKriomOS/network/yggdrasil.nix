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

in
{
  environment.systemPackages = [ package ];

  networking.firewall = {
    allowedTCPPorts = [ ports.linkLocalTCNP ];
  };

  services.yggdrasil = {
    inherit package;
    enable = true;
    settings = yggdrasilConfig;
    openMulticastPort = true;
    persistentKeys = true;
  };
}
