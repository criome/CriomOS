{
  description = "KriomOS - KriOS on Linux";

  inputs = {
    hob.url = github:sajban/hob/fishyThings;
    flake-parts.url = github:hercules-ci/flake-parts;
    mkWebpage = { url = path:./mkWebpage; flake = false; };
    kor = { url = path:./nix/kor; flake = false; };
    mkPkgs = { url = path:./nix/mkPkgs; flake = false; };
    mkDatom = { url = path:./nix/mkDatom; flake = false; };
    mkUyrld = { url = path:./nix/mkUyrld; flake = false; };
    mkKriosfir = { flake = false; url = path:./nix/mkKriosfir; };
    mkKriozonz = { flake = false; url = path:./nix/mkKriozonz; };
    mkKriomOS = { flake = false; url = path:./nix/mkKriomOS; };
    pkdjz = { flake = false; url = path:./nix/pkdjz; };
    homeModule = { flake = false; url = path:./nix/homeModule; };
    neksysNames = { flake = false; url = path:./nix/neksysNames; };
    tests = { url = path:./nix/tests; flake = false; };
    mkKriomDatom = { url = path:./nix/mkKriomDatom; flake = false; };
    files = { url = path:./nix/files; flake = false; };
    AskiCoreNiks = { url = path:./AskiCoreNiks; flake = false; };
    AskiNiks = { url = path:./AskiNiks; flake = false; };
    AskiDefaultBuilder = { url = path:./AskiDefaultBuilder; flake = false; };
  };

  outputs = inputs@{ self, ... }:
    let
      kriomOSRev =
        let shortHash = kor.cortHacString self.narHash;
        in self.shortRev or shortHash;

      localHobSources = {
        inherit (inputs) mkWebpage
          AskiCoreNiks AskiNiks AskiDefaultBuilder;
        pkdjz = { HobUyrldz = import inputs.pkdjz; };
      };

      importInput = name: value:
        import value;

      hob = inputs.hob.Hob // localHobSources;

      inherit (hob) nixpkgs flake-utils emacs-overlay;

      imports = mapAttrs importInput {
        inherit (inputs) kor mkPkgs mkKriosfir mkKriozonz mkKriomOS
          mkHomeConfig neksysNames mkUyrld homeModule files;
      };

      inherit (imports) kor neksysNames mkPkgs homeModule mkKriomOS mkUyrld;

      mkPkgsFromSystem = system:
        let
          overlays = [ emacs-overlay.overlay ];
        in
        mkPkgs { inherit nixpkgs lib system overlays; };

      mkPkgsAndUyrldFromSystem = system:
        let
          pkgs =
            let
              overlays = [ emacs-overlay.overlay ];
            in
            mkPkgs { inherit nixpkgs lib system overlays; };
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
          os = imports.mkKriomOS
            { inherit kriomOSRev kor uyrld hyraizyn homeModule; };
          hom = mapAttrs mkKrimynHomz krimynz;
          imaks = mapAttrs mkKrimynImaks krimynz;
        };

      mkEachKriozonDerivations = kriozonz:
        let
          mkNeksysDerivationIndex = neksysNeim: neksysPrineksysIndeks:
            mapAttrs mkNeksysDerivations neksysPrineksysIndeks;
        in
        mapAttrs mkNeksysDerivationIndex kriozonz;

      perSystemAllOutputs = eachDefaultSystem mkNixApiOutputsPerSystem;

      proposedKriosfir = imports.mkKriosfir { inherit uncheckedKriosfirProposal kor lib; };
      proposedKriozonz = imports.mkKriozonz { inherit kor lib proposedKriosfir; };

      kriomInput = uncheckedKriosfirProposal;
      Kriom = mkKriomDatom { subKrioms = kriomInput; };

    in
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      systems = nixpkgs.lib.systems.flakeExposed;
      imports = [
        inputs.treefmt-nix.flakeModule
        self.flakeModule
      ];
      flake = {
        flakeModules.default = import inputs.flakeModules;
        kriozonz = mkEachKriozonDerivations proposedKriozonz;
        outputs = Kriom.mkOutputs { inherit mkKriomOS kriomOSRev mkPkgsAndUyrld homeModule; };
      };
    };
}
