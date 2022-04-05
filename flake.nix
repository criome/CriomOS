{
  description = "Uniks";

  inputs = {
    bootstrapUniks.url = github:sajban/uniks/spinningTops;

    hob.url = github:sajban/hob/franticSwing;

    KLambdaBootstrap = {
      url = path:./KLambdaBootstrap;
      flake = false;
    };
    ShenAski = {
      url = path:./ShenAski;
      flake = false;
    };
    ShenCoreBootstrap = {
      url = path:./ShenCoreBootstrap;
      flake = false;
    };
    ShenCore = {
      url = path:./ShenCore;
      flake = false;
    };
    ShenCoreTests = {
      url = path:./ShenCoreTests;
      flake = false;
    };
    ShenExtendedBootstrap = {
      url = path:./ShenExtendedBootstrap;
      flake = false;
    };
    ShenExtended = {
      url = path:./ShenExtended;
      flake = false;
    };
    ShenExtendedTests = {
      url = path:./ShenExtendedTests;
      flake = false;
    };
    LispCore = {
      url = path:./LispCore;
      flake = false;
    };
    LispCorePrimitives = {
      url = path:./LispCorePrimitives;
      flake = false;
    };
    LispExtendedPrimitives = {
      url = path:./LispExtendedPrimitives;
      flake = false;
    };
    AskiCore = {
      url = path:./AskiCore;
      flake = false;
    };
    AskiCoreFleik = {
      url = path:./AskiCoreFleik;
      flake = false;
    };
    AskiCoreUniks = {
      url = path:./AskiCoreUniks;
      flake = false;
    };
    AskiUniks = {
      url = path:./AskiUniks;
      flake = false;
    };
    AskiDefaultBuilder = {
      url = path:./AskiDefaultBuilder;
      flake = false;
    };
    mkWebpage = {
      url = path:./nix/pkdjz/mkWebpage/src;
      flake = false;
    };
  };

  outputs = inputs@{ self, ... }:
    let
      mkHobSpokMein = name: mein: { inherit mein; };

      localHobSourcesRaw = {
        inherit (inputs)
          KLambdaBootstrap LispCore LispCorePrimitives LispExtendedPrimitives
          ShenAski ShenCoreBootstrap ShenCore ShenCoreTests
          ShenExtendedBootstrap ShenExtended ShenExtendedTests
          AskiCore AskiCoreFleik mkWebpage
          AskiCoreUniks AskiUniks AskiDefaultBuilder;
      };

      localHobSources = mapAttrs mkHobSpokMein localHobSourcesRaw;

      hob = inputs.hob.Hob // localHobSources;
      nixpkgs = hob.nixpkgs.mein;
      flake-utils = hob.flake-utils.mein;
      emacs-overlay = hob.emacs-overlay.mein;

      kor = import ./nix/kor.nix;
      mkKriosfir = import ./nix/mkKriosfir;
      mkKriozonz = import ./nix/mkKriozonz;
      mkUniksOS = import ./nix/mkUniksOS;
      mkHom = import ./nix/mkHom;
      neksysNames = import ./neksysNames.nix;

      inherit (builtins) fold attrNames mapAttrs filterAttrs;
      inherit (nixpkgs) lib;
      inherit (kor) mkLamdy arkSistymMap genAttrs;
      inherit (flake-utils.lib) eachDefaultSystem;

      generateKriosfirProposalFromName = name:
        hob."${name}".mein.NeksysProposal or { };

      uncheckedKriosfirProposal = genAttrs
        neksysNames
        generateKriosfirProposalFromName;

      mkNeksysDerivations = priNeksysNeim: kriozon:
        let
          inherit (kriozon) krimynz;
          inherit (kriozon.astra.mycin) ark;
          system = arkSistymMap.${ark};
          uyrld = self.uyrld.${system};
          hyraizyn = kriozon;
          src = self;

          krimynProfiles = {
            light = { dark = false; };
            dark = { dark = true; };
          };

          mkKrimynHomz = krimynNeim: krimyn:
            let
              emacsPkgs = uyrld.pkdjz.meikPkgs {
                overlays = [ emacs-overlay.overlay ];
              };
              pkgs =
                if (krimyn.stail == "emacs")
                then emacsPkgs
                else nixpkgs.legacyPackages.${system};
              home-manager = hob.home-manager.mein;
              mkProfileHom = profileName: profile:
                mkHom {
                  inherit lib kor uyrld kriozon krimyn
                    profile hob home-manager pkgs;
                };
            in
            mapAttrs mkProfileHom krimynProfiles;

          mkKrimynImaks = krimynNeim: krimyn:
            let
              inherit (uyrld.pkdjz) meikImaks;
              mkProfileImaks = profileName: profile:
                meikImaks { inherit kriozon krimyn profile; };
            in
            mapAttrs mkProfileImaks krimynProfiles;

        in
        {
          os = mkUniksOS { inherit src nixpkgs kor uyrld hyraizyn; };
          hom = mapAttrs mkKrimynHomz krimynz;
          imaks = mapAttrs mkKrimynImaks krimynz;
        };

      mkEachKriozonDerivations = kriozonz:
        let
          mkNeksysDerivationIndex = neksysNeim: neksysPrineksysIndeks:
            mapAttrs mkNeksysDerivations neksysPrineksysIndeks;
        in
        mapAttrs mkNeksysDerivationIndex kriozonz;

      mkOutputs = system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          inherit (pkgs) symlinkJoin linkFarm;
          bootstrapUyrld = inputs.bootstrapUniks.uyrld.${system};
          mkUyrld = import ./nix/mkUyrld.nix;
          uyrld = mkUyrld {
            inherit pkgs kor lib system hob
              neksysNames bootstrapUyrld;
          };
          inherit (uyrld.pkdjz) shen-ecl-bootstrap;
          shen = shen-ecl-bootstrap;

          legacyPackages = pkgs;
          defaultPackage = shen;

          devShell = pkgs.mkShell {
            inputsFrom = [ ];
            UNIKSBOOTFILE = self + /boot.shen;
            buildInputs = [ shen ];
          };

          mkSpokBranch = name: src:
            symlinkJoin { inherit name; paths = [ src.outPath ]; };

          mkSpokOutputs = name: branches:
            mapAttrs mkSpokBranch branches;

          hobOutputs = mapAttrs mkSpokOutputs hob;

          mkSpokFarmEntry = name: spok:
            { inherit name; path = spok.mein.outPath; };

          allMeinHobOutputs = linkFarm "hob.mein"
            (kor.mapAttrsToList mkSpokFarmEntry hobOutputs);

          packages = uyrld // {
            inherit pkgs;
            hob = hobOutputs;
            fullHob = allMeinHobOutputs;
          };

        in
        { inherit uyrld legacyPackages packages defaultPackage devShell; };

      perSystemOutputs = eachDefaultSystem mkOutputs;

      proposedKriosfir = mkKriosfir { inherit uncheckedKriosfirProposal kor lib; };
      proposedKriozonz = mkKriozonz { inherit kor lib proposedKriosfir; };

    in
    perSystemOutputs // {
      kriozonz = mkEachKriozonDerivations proposedKriozonz;
    };
}
