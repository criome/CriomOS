{ kor, lib, pkgs, hyraizyn, uyrld, konstynts, ... }:
let
  inherit (builtins) mapAttrs attrNames filter;
  inherit (lib) boolToString;
  inherit (kor) optionals mkIf optional eksportJSON;

  inherit (hyraizyn.metastra.spinyrz) trostydBildPriKriomz;
  inherit (hyraizyn) astra;
  inherit (hyraizyn.astra.spinyrz) exAstrizEseseitcPriKriomz
    bildyrKonfigz kacURLz dispatcyrzEseseitcKiz saizAtList
    izBildyr izNiksKac izDispatcyr izKriodaizd;

  inherit (konstynts.fileSystem.niks) priKriad;
  inherit (konstynts.network.niks) serve;

  jsonHyraizynFail = eksportJSON "hyraizyn.json" hyraizyn;

  niksRegistry = {
    flakes = [{
      from = {
        type = "indirect";
        id = "niks";
      };
      to = {
        type = "github";
        owner = "sajban";
        repo = "niks";
      };
    }];
    version = 2;
  };

  redjistri = eksportJSON "niksRegistry.json"
    niksRegistry;

in
{
  environment.etc."hyraizyn.json" = {
    source = jsonHyraizynFail;
    mode = "0600";
  };

  networking = {
    hostName = astra.neim;
    dhcpcd.extraConfig = "noipv4ll";
  };

  nix = {
    package = uyrld.nix.defaultPackage;

    trustedUsers = [ "root" "@nixdev" ];

    allowedUsers = [ "@users" "nix-serve" ]
      ++ optional izBildyr "niksBildyr";

    buildCores = astra.nbOfBildKorz;

    sandboxPaths = [
      # "/links"  # TODO
    ];

    binaryCachePublicKeys = trostydBildPriKriomz;
    binaryCaches = kacURLz;
    trustedBinaryCaches = kacURLz;

    autoOptimiseStore = true;

    # Lowest priorities
    daemonCPUSchedPolicy = "idle";
    daemonIOSchedPriority = 7;

    extraOptions = ''
      flake-registry = ${redjistri}
      experimental-features = nix-command flakes recursive-nix
      secret-key-files = ${priKriad}
      keep-derivations = ${boolToString saizAtList.med}
      keep-outputs = ${boolToString saizAtList.max}
      !include nixTokens
    '';

    sshServe = {
      enable = izNiksKac;
      keys = exAstrizEseseitcPriKriomz;
      protocol = "ssh";
    };

    distributedBuilds = izDispatcyr;
    buildMachines = optionals izDispatcyr bildyrKonfigz;

  };

  users = {
    groups = {
      nixdev = { };
      niksBildyr = { };
    };
    users = mkIf izBildyr {
      niksBildyr = {
        isNormalUser = true;
        useDefaultShell = true;
        openssh.authorizedKeys.keys = dispatcyrzEseseitcKiz;
      };
    };

  };

  services = {
    nix-serve = {
      enable = false; # (broken missingUserHomeDir)
      bindAddress = "127.0.0.1";
      port = serve.ports.internal;
      secretKeyFile = priKriad;
    };

    nginx = mkIf (izNiksKac && izKriodaizd) {
      enable = false; # (brokenDependency nixServe)
      virtualHosts = {
        "[${astra.yggAddress}]:${toString serve.ports.external}" = {
          listen = [{ addr = "[${astra.yggAddress}]"; port = serve.ports.external; }];
          locations."/".proxyPass = "http://127.0.0.1:${toString serve.ports.internal}";
        };
      };
    };

  };

}
