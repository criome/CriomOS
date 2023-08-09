{ kor, lib, pkgs, hyraizyn, uyrld, konstynts, config, ... }:
with builtins;
let
  inherit (lib) boolToString mapAttrsToList importJSON;
  inherit (kor) optionals mkIf optional eksportJSON optionalAttrs;

  inherit (hyraizyn.metastra.spinyrz) trostydBildPriKriomz;
  inherit (hyraizyn) astra;
  inherit (hyraizyn.astra.spinyrz) exAstrizEseseitcPriKriomz
    bildyrKonfigz kacURLz dispatcyrzEseseitcKiz saizAtList
    izBildyr izNiksKac izDispatcyr izKriodaizd izNiksKriodaizd
    nixCacheDomain;

  inherit (konstynts.fileSystem.niks) priKriad;
  inherit (konstynts.network.niks) serve;
  inherit (konstynts.fileSystem) yggdrasil;

  jsonHyraizynFail = eksportJSON "hyraizyn.json" hyraizyn;

  flakeEntriesOverrides = {
    hob = {
      type = "github";
      owner = "sajban";
      repo = "hob";
      ref = "secondLanding"; # (TODO kriomOSVersion)
    };
    kriomOS = {
      type = "github";
      owner = "sajban";
      repo = "kriomOS";
      ref = "secondLanding"; # (TODO kriomOSVersion)
    };
    nixpkgs = {
      type = "github";
      owner = "sajban";
      repo = "nixpkgs";
      ref = "secondLanding"; # (TODO kriomOSVersion)
    };
    nixpkgs-master = {
      type = "github";
      owner = "NixOS";
      repo = "nixpkgs";
      ref = "85963eba3a76ff2ae4928b9d5de45cbfe9eee2d8"; # (TODO kriomOSVersion)
    };

    xdg-desktop-portal-hyprland = {
      type = "github";
      owner = "hyprwm";
      repo = "xdg-desktop-portal-hyprland";
    };
  };

  mkFlakeEntriesListFromSet = entriesMap:
    let
      mkFlakeEntry = name: value: {
        from = { type = "indirect"; id = name; };
        to = value;
      };
    in
    mapAttrsToList mkFlakeEntry entriesMap;

  kriomOSFlakeEntries = mkFlakeEntriesListFromSet flakeEntriesOverrides;

  nixOSFlakeEntries =
    let nixOSFlakeRegistry = importJSON uyrld.pkdjz.flake-registry;
    in nixOSFlakeRegistry.flakes;

  filterOutRegistry = entry:
    let
      flakeName = entry.from.id;
      flakeOverrideNames = attrNames flakeEntriesOverrides;
      entryIsOverridden = elem flakeName flakeOverrideNames;
    in
      !(entryIsOverridden);

  filteredNixosFlakeEntries = filter filterOutRegistry nixOSFlakeEntries;

  nixFlakeRegistry = {
    flakes = kriomOSFlakeEntries ++ filteredNixosFlakeEntries;
    version = 2;
  };

  nixFlakeRegistryJson = eksportJSON "nixFlakeRegistry.json"
    nixFlakeRegistry;

in
{
  environment.etc."hyraizyn.json" = {
    source = jsonHyraizynFail;
    mode = "0600";
  };

  networking = {
    firewall = {
      allowedTCPPorts = optionals izNiksKac [ serve.ports.external 80 ];
    };
  };

  nix = {
    package = pkgs.nixUnstable;

    settings = {
      trusted-users = [ "root" "@nixdev" ] ++ optional izBildyr "nixBuilder";

      allowed-users = [ "@users" "nix-serve" ];

      build-cores = astra.nbOfBildKorz;

      connect-timeout = 5;
      fallback = true;

      trusted-public-keys = trostydBildPriKriomz;
      substituters = kacURLz;
      trusted-binary-caches = kacURLz;

      auto-optimise-store = true;
    };

    # Lowest priorities
    daemonCPUSchedPolicy = "idle";
    daemonIOSchedPriority = 7;

    extraOptions = ''
      flake-registry = ${nixFlakeRegistryJson}
      experimental-features = nix-command flakes recursive-nix
      secret-key-files = ${priKriad}
      keep-derivations = ${boolToString saizAtList.med}
      keep-outputs = ${boolToString saizAtList.max}
      !include nixTokens
    '';

    distributedBuilds = izDispatcyr;
    buildMachines = optionals izDispatcyr bildyrKonfigz;

  };

  users = {
    groups = { nixdev = { }; }
      // (optionalAttrs izBildyr { nixBuilder = { }; })
      // (optionalAttrs izNiksKac { nix-serve = { gid = 199; }; });

    users = (optionalAttrs izNiksKac {
      nix-serve = {
        uid = 199;
        group = "nix-serve";
      };
    }) // (optionalAttrs izBildyr {
      nixBuilder = {
        isNormalUser = true;
        useDefaultShell = true;
        openssh.authorizedKeys.keys = dispatcyrzEseseitcKiz;
      };
    });

  };

  services = {


    nginx = mkIf izNiksKac {
      enable = true;
      virtualHosts = {
        "[${astra.yggAddress}]:${toString serve.ports.external}" = {
          listen = [{ addr = "[${astra.yggAddress}]"; port = serve.ports.external; }];
          locations."/".proxyPass = "http://127.0.0.1:${toString serve.ports.internal}";
        };
        "${nixCacheDomain}" = {
          listen = [{ addr = "[${astra.yggAddress}]"; port = 80; }];
          locations."/".proxyPass = "http://127.0.0.1:${toString serve.ports.internal}";
        };
      };
    };

  };

  systemd.services = optionalAttrs izNiksKac (
    let
      cfg = {
        bindAddress = "127.0.0.1";
        port = serve.ports.internal;
        secretKeyFile = priKriad;
        extraParams = "";
      };
    in
    {
      nix-serve = {
        description = "nix-serve binary cache server";
        after = [ "network.target" ];
        wantedBy = [ "multi-user.target" ];

        path = [ config.nix.package.out pkgs.bzip2.bin ];
        environment = {
          NIX_REMOTE = "daemon";
          HOME = "$STATE_DIRECTORY";
        };

        script = ''
          ${lib.optionalString (cfg.secretKeyFile != null) ''
            export NIX_SECRET_KEY_FILE="$CREDENTIALS_DIRECTORY/NIX_SECRET_KEY_FILE"
          ''}
          exec ${pkgs.nix-serve}/bin/nix-serve --listen ${cfg.bindAddress}:${toString cfg.port} ${cfg.extraParams}
        '';

        serviceConfig = {
          Restart = "always";
          RestartSec = "5s";
          User = "nix-serve";
          Group = "nix-serve";
          StateDirectory = "nix-serve";
          LoadCredential = lib.optionalString (cfg.secretKeyFile != null)
            "NIX_SECRET_KEY_FILE:${cfg.secretKeyFile}";
        };
      }
      // optionalAttrs (!izNiksKriodaizd) ({
        mkNixPreKriad = {
          description = "";
          wantedBy = [ "multi-user.target" ];
          serviceConfig = { type = "oneshot"; };
          script = ''
            nix key generate-secret --key-name ${astra.kriomOSNeim} > ${priKriad}
          '';
        };
      });
    }
  );
}
