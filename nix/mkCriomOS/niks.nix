{ kor, lib, pkgs, hob, hyraizyn, uyrld, konstynts, config, ... }:
with builtins;
let
  inherit (lib) boolToString mapAttrsToList importJSON;
  inherit (kor) optionals mkIf optional eksportJSON optionalAttrs;

  inherit (hyraizyn.metastra.spinyrz) trostydBildPreCriomes;
  inherit (hyraizyn) astra;
  inherit (hyraizyn.astra.spinyrz)
    bildyrKonfigz kacURLz dispatcyrzEseseitcKiz saizAtList
    izBildyr izNiksKac izDispatcyr izNiksCriodaizd
    nixCacheDomain;

  inherit (konstynts.fileSystem.niks) preCriad;
  inherit (konstynts.network.niks) serve;

  jsonHyraizynFail = eksportJSON "hyraizyn.json" hyraizyn;

  flakeEntriesOverrides = {
    blank = { owner = "divnix"; };
    incl = { owner = "divnix"; };
    haumea = { owner = "nix-community"; ref = "v0.2.2"; };
    paisano = { owner = "paisano-nix"; repo = "core"; };
    paisano-tui = { owner = "paisano-nix"; repo = "tui"; ref = "0.2.0"; };
    dmerge = { owner = "divnix"; ref = "0.2.1"; };
    yants = { owner = "divnix"; };
    std = { owner = "LiGoldragon"; ref = "fixLibFollows"; };
    call-flake = { owner = "divnix"; };
    nosys = { owner = "divnix"; };
    devshell = { owner = "numtide"; };
    nixago = { owner = "nix-community"; };
    clj-nix = { owner = "jlesquembre"; };

    flakeWorld = { owner = "sajban"; };
    hob = { owner = "sajban"; ref = "autumnCleaning"; };
    criomeOS = { owner = "sajban"; ref = "newHorizons"; };

    lib = { owner = "nix-community"; repo = "nixpkgs.lib"; };

    nixpkgs = {
      owner = "NixOS";
      repo = "nixpkgs";
      inherit (hob.nixpkgs) rev;
    } // optionalAttrs (hob.nixpkgs ? ref) { inherit (hob.nixpkgs) ref; };

    nixpkgs-master = { owner = "NixOS"; repo = "nixpkgs"; };

    xdg-desktop-portal-hyprland = { owner = "hyprwm"; };
  };

  mkFlakeEntriesListFromSet = entriesMap:
    let
      mkFlakeEntry = name: value: {
        from = {
          id = name;
          type = "indirect";
        };
        to = ({ repo = name; type = "github"; } // value);
      };
    in
    mapAttrsToList mkFlakeEntry entriesMap;

  criomeOSFlakeEntries = mkFlakeEntriesListFromSet flakeEntriesOverrides;

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
    flakes = criomeOSFlakeEntries ++ filteredNixosFlakeEntries;
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

      trusted-public-keys = trostydBildPreCriomes;
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
      secret-key-files = ${preCriad}
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
        secretKeyFile = preCriad;
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
      // optionalAttrs (!izNiksCriodaizd) ({
        mkNixPreCriad = {
          description = "";
          wantedBy = [ "multi-user.target" ];
          serviceConfig = { type = "oneshot"; };
          script = ''
            nix key generate-secret --key-name ${astra.criomeOSNeim} > ${preCriad}
          '';
        };
      });
    }
  );
}
