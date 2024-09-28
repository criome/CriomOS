{
  description = "CriomOS";

  inputs = { hob.url = "github:criome/hob/1Libra5918AM-update"; };

  outputs = inputs@{ self, ... }:
    let
      localSources =
        let
          importInput = name: value:
            import value;
          modulePaths = {
            kor = ./nix/kor;
            mkPkgs = ./nix/mkPkgs;
            mkDatom = ./nix/mkDatom;
            mkUyrld = ./nix/mkUyrld;
            mkCrioSphere = ./nix/mkCrioSphere;
            mkCrioZones = ./nix/mkCrioZones;
            mkCriomOS = ./nix/mkCriomOS;
            pkdjz = ./nix/pkdjz;
            homeModule = ./nix/homeModule;
            neksysNames = ./neksysNames.nix;
            tests = ./nix/tests;
            files = ./nix/files;
          };
        in
        mapAttrs importInput modulePaths;

      localHobSources = {
        inherit (localSources) mkWebpage;
        pkdjz = { HobUyrldz = localSources.pkdjz; };
      };

      hob = inputs.hob.value // localHobSources;

      inherit (hob) flake-utils emacs-overlay nixpkgs lib;
      inherit (localSources) kor neksysNames mkPkgs homeModule mkCriomOS mkUyrld;
      inherit (lib) optionalAttrs genAttrs hasAttr;

      criomOS =
        let
          cleanEvaluation = hasAttr "rev" self;
        in
        { inherit cleanEvaluation; }
        // optionalAttrs cleanEvaluation
          { inherit (self) shortRev rev; };

      mkPkgsAndUyrldFromSystem = system:
        let
          pkgs =
            let
              overlays = [ emacs-overlay.overlay ];
            in
            mkPkgs { inherit nixpkgs lib system overlays; };
          uyrld = mkUyrld { inherit lib pkgs system hob localSources; };
        in
        { inherit pkgs uyrld; };

      perSystemPkgsAndUyrld = eachDefaultSystem mkPkgsAndUyrldFromSystem;

      mkPkgsAndUyrld = system:
        mapAttrs (name: value: value.${system}) perSystemPkgsAndUyrld;

      mkDatom = import inputs.mkDatom { inherit kor lib; };

      inherit (builtins) mapAttrs;
      inherit (kor) arkSistymMap;
      inherit (flake-utils.lib) eachDefaultSystem;

      generateCrioSphereProposalFromName = name:
        let
          subCriomeConfig = hob."${name}".NeksysProposal or { };
          explicitNodes = subCriomeConfig.astriz or { };
          implicitNodes = import ./implicitNodes.nix;
          allNodes = explicitNodes // implicitNodes;
        in
        subCriomeConfig // { astriz = allNodes; };

      uncheckedCrioSphereProposal = genAttrs
        neksysNames
        generateCrioSphereProposalFromName;

      mkNeksysDerivations = priNeksysNeim: crioZone:
        let
          inherit (crioZone) users;
          inherit (crioZone.astra.mycin) ark;
          system = arkSistymMap.${ark};
          pkgsAndUyrld = mkPkgsAndUyrld system;
          inherit (pkgsAndUyrld) pkgs uyrld;
          hyraizyn = crioZone;

          userProfiles = {
            light = { dark = false; };
            dark = { dark = true; };
          };

          mkUserHomz = userNeim: user:
            let
              inherit (uyrld) pkdjz;

              mkProfileHom = profileName: profile:
                let
                  modules = [ homeModule ];
                  extraSpecialArgs =
                    { inherit kor pkdjz uyrld hyraizyn user profile; };
                  evalHomeManager = hob.home-manager.lib.homeManagerConfiguration;
                  evaluation = evalHomeManager
                    { inherit modules extraSpecialArgs pkgs; };
                in
                evaluation.config.home.activationPackage;
            in
            mapAttrs mkProfileHom userProfiles;

          mkUserImaks = userNeim: user:
            let
              inherit (uyrld.pkdjz) meikImaks;
              mkProfileImaks = profileName: profile:
                meikImaks { inherit user profile; };
            in
            mapAttrs mkProfileImaks userProfiles;

        in
        {
          os = mkCriomOS
            { inherit criomOS kor uyrld hyraizyn homeModule hob; };
          hom = mapAttrs mkUserHomz users;
          imaks = mapAttrs mkUserImaks users;
        };

      mkEachCrioZoneDerivations = crioZones:
        let
          mkNeksysDerivationIndex = neksysNeim: neksysPrineksysIndeks:
            mapAttrs mkNeksysDerivations neksysPrineksysIndeks;
        in
        mapAttrs mkNeksysDerivationIndex crioZones;

      mkNixApiOutputsPerSystem = system:
        let
          pkgsAndUyrld = mkPkgsAndUyrld system;
          inherit (pkgsAndUyrld) pkgs uyrld;
          inherit (pkgs) symlinkJoin linkFarm;

          devShell = pkgs.mkShell {
            # TODO
          };

          mkHobOutput = name: src:
            symlinkJoin { inherit name; paths = [ src.outPath ]; };

          hobOutputs = mapAttrs mkHobOutput hob;

          mkSpokFarmEntry = name: spok:
            { inherit name; path = spok.outPath; };

          allMeinHobOutputs = linkFarm "hob"
            (kor.mapAttrsToList mkSpokFarmEntry hobOutputs);

          packages = uyrld // {
            inherit pkgs;
            hob = hobOutputs;
            fullHob = allMeinHobOutputs;
          };

          tests = import inputs.tests { inherit lib mkDatom; };

        in
        { inherit tests packages devShell; };

      perSystemAllOutputs = eachDefaultSystem mkNixApiOutputsPerSystem;

      proposedCrioSphere = localSources.mkCrioSphere { inherit uncheckedCrioSphereProposal kor lib; };
      proposedCrioZones = localSources.mkCrioZones { inherit kor lib proposedCrioSphere; };

    in
    perSystemAllOutputs // {
      crioZones = mkEachCrioZoneDerivations proposedCrioZones;
    };
}
