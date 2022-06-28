{
  description = "Krioniks";

  inputs = {
    hob.url = github:sajban/hob/simplerHob;
    KLambdaBootstrap = { url = path:./KLambdaBootstrap; flake = false; };
    ShenAski = { url = path:./ShenAski; flake = false; };
    ShenCoreBootstrap = { url = path:./ShenCoreBootstrap; flake = false; };
    ShenCore = { url = path:./ShenCore; flake = false; };
    ShenCoreTests = { url = path:./ShenCoreTests; flake = false; };
    ShenExtendedBootstrap = { url = path:./ShenExtendedBootstrap; flake = false; };
    ShenExtended = { url = path:./ShenExtended; flake = false; };
    ShenExtendedTests = { url = path:./ShenExtendedTests; flake = false; };
    LispCore = { url = path:./LispCore; flake = false; };
    LispCorePrimitives = { url = path:./LispCorePrimitives; flake = false; };
    LispExtendedPrimitives = { url = path:./LispExtendedPrimitives; flake = false; };
    AskiCore = { url = path:./AskiCore; flake = false; };
    AskiCoreFleik = { url = path:./AskiCoreFleik; flake = false; };
    AskiCoreNiks = { url = path:./AskiCoreNiks; flake = false; };
    AskiNiks = { url = path:./AskiNiks; flake = false; };
    AskiDefaultBuilder = { url = path:./AskiDefaultBuilder; flake = false; };
    mkWebpage = { url = path:./mkWebpage; flake = false; };
    kor = { url = path:./nix/kor; flake = false; };
    mkDatom = { url = path:./nix/mkDatom; flake = false; };
    mkUyrld = { url = path:./nix/mkUyrld; flake = false; };
    mkKriosfir = { flake = false; url = path:./nix/mkKriosfir; };
    mkKriozonz = { flake = false; url = path:./nix/mkKriozonz; };
    mkKrioniks = { flake = false; url = path:./nix/mkKrioniks; };
    pkdjz = { flake = false; url = path:./nix/pkdjz; };
    mkHom = { flake = false; url = path:./nix/mkHom; };
    neksysNames = { flake = false; url = path:./nix/neksysNames; };
    tests = { url = path:./nix/tests; flake = false; };
  };

  outputs = inputs@{ self, ... }:
    let
      localHobSources = {
        inherit (inputs) KLambdaBootstrap LispCore LispCorePrimitives
          LispExtendedPrimitives ShenAski ShenCoreBootstrap ShenCore
          ShenCoreTests ShenExtendedBootstrap ShenExtended ShenExtendedTests
          AskiCore AskiCoreFleik AskiCoreNiks AskiNiks AskiDefaultBuilder
          mkWebpage;

        pkdjz = { HobUyrldz = import inputs.pkdjz; };
      };

      hob = inputs.hob.Hob // localHobSources;
      nixpkgs = hob.nixpkgs;
      nextNixpkgs = hob.nextNixpkgs;
      flake-utils = hob.flake-utils;
      emacs-overlay = hob.emacs-overlay;

      kor = import inputs.kor;
      mkKriosfir = import inputs.mkKriosfir;
      mkKriozonz = import inputs.mkKriozonz;
      mkKrioniks = import inputs.mkKrioniks;
      mkHom = import inputs.mkHom;
      neksysNames = import inputs.neksysNames;
      mkUyrld = import inputs.mkUyrld;
      mkDatom = import inputs.mkDatom { inherit kor lib; };

      inherit (builtins) fold attrNames mapAttrs filterAttrs;
      inherit (nixpkgs) lib;
      inherit (kor) mkLamdy arkSistymMap genAttrs;
      inherit (flake-utils.lib) eachDefaultSystem;

      generateKriosfirProposalFromName = name:
        hob."${name}".NeksysProposal or { };

      uncheckedKriosfirProposal = genAttrs
        neksysNames
        generateKriosfirProposalFromName;

      mkNeksysDerivations = priNeksysNeim: kriozon:
        let
          inherit (kriozon) krimynz;
          inherit (kriozon.astra.mycin) ark;
          system = arkSistymMap.${ark};
          uyrld = self.uyrld.${system};
          nextPkgs = nextNixpkgs.legacyPackages.${system};
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
              home-manager = hob.home-manager;
              mkProfileHom = profileName: profile:
                mkHom {
                  inherit lib kor uyrld kriozon krimyn
                    profile hob home-manager pkgs nextPkgs;
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
          os = mkKrioniks { inherit src nixpkgs kor uyrld hyraizyn; };
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
          nextPkgs = nextNixpkgs.legacyPackages.${system};
          inherit (pkgs) symlinkJoin linkFarm;
          uyrld = mkUyrld {
            inherit pkgs kor lib system hob
              neksysNames nextPkgs;
          };
          inherit (uyrld.pkdjz) shen-ecl-bootstrap;
          shen = shen-ecl-bootstrap;

          legacyPackages = pkgs;
          defaultPackage = shen;

          devShell = pkgs.mkShell {
            inputsFrom = [ ];
            KRIONIKSBOOTFILE = self + /boot.shen;
            buildInputs = [ shen ];
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
        {
          inherit uyrld legacyPackages tests
            packages defaultPackage devShell;
        };

      perSystemOutputs = eachDefaultSystem mkOutputs;

      proposedKriosfir = mkKriosfir { inherit uncheckedKriosfirProposal kor lib; };
      proposedKriozonz = mkKriozonz { inherit kor lib proposedKriosfir; };

    in
    perSystemOutputs // {
      kriozonz = mkEachKriozonDerivations proposedKriozonz;
    };
}
