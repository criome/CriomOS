{
  description = "Krioniks";

  inputs = {
    hob.url = github:sajban/hob/itsBedTime;
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
    mkPkgs = { url = path:./nix/mkPkgs; flake = false; };
    mkDatom = { url = path:./nix/mkDatom; flake = false; };
    mkUyrld = { url = path:./nix/mkUyrld; flake = false; };
    mkKriosfir = { flake = false; url = path:./nix/mkKriosfir; };
    mkKriozonz = { flake = false; url = path:./nix/mkKriozonz; };
    mkKrioniks = { flake = false; url = path:./nix/mkKrioniks; };
    pkdjz = { flake = false; url = path:./nix/pkdjz; };
    homeModule = { flake = false; url = path:./nix/homeModule; };
    neksysNames = { flake = false; url = path:./nix/neksysNames; };
    tests = { url = path:./nix/tests; flake = false; };
    mkKriomDatom = { url = path:./nix/mkKriomDatom; flake = false; };
    files = { url = path:./nix/files; flake = false; };
  };

  outputs = inputs@{ self, ... }:
    let
      krioniksRev =
        let shortHash = kor.cortHacString self.narHash;
        in self.shortRev or shortHash;

      localHobSources = {
        inherit (inputs) KLambdaBootstrap LispCore LispCorePrimitives
          LispExtendedPrimitives ShenAski ShenCoreBootstrap ShenCore
          ShenCoreTests ShenExtendedBootstrap ShenExtended ShenExtendedTests
          AskiCore AskiCoreFleik AskiCoreNiks AskiNiks AskiDefaultBuilder
          mkWebpage;

        pkdjz = { HobUyrldz = import inputs.pkdjz; };
      };

      importInput = name: value:
        import value;

      hob = inputs.hob.Hob // localHobSources;

      inherit (hob) nixpkgs flake-utils emacs-overlay;

      imports = mapAttrs importInput {
        inherit (inputs) kor mkPkgs mkKriosfir mkKriozonz mkKrioniks
          mkHomeConfig neksysNames mkUyrld homeModule files;
      };

      inherit (imports) kor neksysNames mkPkgs homeModule mkKrioniks mkUyrld;

      mkPkgsFromSystem = system:
        let
          config = { allowUnfree = true; };
          overlays = [ emacs-overlay.overlay ];
        in
        mkPkgs { inherit nixpkgs lib system config overlays; };

      mkPkgsAndUyrldFromSystem = system:
        let
          pkgs =
            let
              config = { allowUnfree = true; };
              overlays = [ emacs-overlay.overlay ];
            in
            mkPkgs { inherit nixpkgs lib system config overlays; };
          uyrld = mkUyrld { inherit pkgs kor lib system hob neksysNames; };
        in
        { inherit pkgs uyrld; };

      perSystemPkgsAndUyrld = eachDefaultSystem mkPkgsAndUyrldFromSystem;

      mkPkgsAndUyrld = system:
        mapAttrs (name: value: value.${system}) perSystemPkgsAndUyrld;

      mkDatom = import inputs.mkDatom { inherit kor lib; };
      mkKriomDatom = import inputs.mkKriomDatom { inherit kor lib mkDatom; };

      inherit (builtins) fold attrNames mapAttrs filterAttrs;
      inherit (nixpkgs) lib;
      inherit (kor) mkLamdy arkSistymMap genAttrs;
      inherit (flake-utils.lib) eachDefaultSystem;

      generateKriosfirProposalFromName = name:
        let
          subKriomConfig = hob."${name}".NeksysProposal or { };
          explicitNodes = subKriomConfig.astriz or { };
          implicitNodes = import ./implicitNodes.nix;
          allNodes = explicitNodes // implicitNodes;
        in
        subKriomConfig // { astriz = allNodes; };

      uncheckedKriosfirProposal = genAttrs
        neksysNames
        generateKriosfirProposalFromName;

      mkNeksysDerivations = priNeksysNeim: kriozon:
        let
          inherit (kriozon) krimynz;
          inherit (kriozon.astra.mycin) ark;
          system = arkSistymMap.${ark};
          pkgsAndUyrld = mkPkgsAndUyrld system;
          inherit (pkgsAndUyrld) pkgs uyrld;
          hyraizyn = kriozon;

          krimynProfiles = {
            light = { dark = false; };
            dark = { dark = true; };
          };

          mkKrimynHomz = krimynNeim: krimyn:
            let
              inherit (uyrld) pkdjz;

              mkProfileHom = profileName: profile:
                let
                  modules = [ homeModule ];
                  extraSpecialArgs =
                    { inherit kor pkdjz uyrld hyraizyn krimyn profile; };
                  evalHomeManager = hob.home-manager.lib.homeManagerConfiguration;
                  evaluation = evalHomeManager
                    { inherit modules extraSpecialArgs pkgs; };
                in
                evaluation.config.home.activationPackage;
            in
            mapAttrs mkProfileHom krimynProfiles;

          mkKrimynImaks = krimynNeim: krimyn:
            let
              inherit (uyrld.pkdjz) meikImaks;
              mkProfileImaks = profileName: profile:
                meikImaks { inherit krimyn profile; };
            in
            mapAttrs mkProfileImaks krimynProfiles;

        in
        {
          os = imports.mkKrioniks
            { inherit krioniksRev kor uyrld hyraizyn homeModule; };
          hom = mapAttrs mkKrimynHomz krimynz;
          imaks = mapAttrs mkKrimynImaks krimynz;
        };

      mkEachKriozonDerivations = kriozonz:
        let
          mkNeksysDerivationIndex = neksysNeim: neksysPrineksysIndeks:
            mapAttrs mkNeksysDerivations neksysPrineksysIndeks;
        in
        mapAttrs mkNeksysDerivationIndex kriozonz;

      mkNixApiOutputsPerSystem = system:
        let
          pkgsAndUyrld = mkPkgsAndUyrld system;
          inherit (pkgsAndUyrld) pkgs uyrld;
          inherit (pkgs) symlinkJoin linkFarm;

          inherit (uyrld.pkdjz) shen-ecl-bootstrap;
          shen = shen-ecl-bootstrap;

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
        { inherit tests packages devShell; };

      perSystemAllOutputs = eachDefaultSystem mkNixApiOutputsPerSystem;

      proposedKriosfir = imports.mkKriosfir { inherit uncheckedKriosfirProposal kor lib; };
      proposedKriozonz = imports.mkKriozonz { inherit kor lib proposedKriosfir; };

      kriomInput = uncheckedKriosfirProposal;
      Kriom = mkKriomDatom { subKrioms = kriomInput; };

    in
    perSystemAllOutputs // {
      kriozonz = mkEachKriozonDerivations proposedKriozonz;
      outputs = Kriom.mkOutputs { inherit mkKrioniks krioniksRev mkPkgsAndUyrld homeModule; };
    };
}
