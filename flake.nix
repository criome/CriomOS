{
  description = "KriomOS - KriOS on Linux";

  inputs = {
    hob.url = "github:sajban/hob/23Aries5918AM-Update";

    mkWebpage = { url = "path:./mkWebpage"; flake = false; };
    kor = { url = "path:./nix/kor"; flake = false; };
    mkPkgs = { url = "path:./nix/mkPkgs"; flake = false; };
    mkDatom = { url = "path:./nix/mkDatom"; flake = false; };
    mkUyrld = { url = "path:./nix/mkUyrld"; flake = false; };
    mkKriosfir = { flake = false; url = "path:./nix/mkKriosfir"; };
    mkKriozonz = { flake = false; url = "path:./nix/mkKriozonz"; };
    mkKriomOS = { flake = false; url = "path:./nix/mkKriomOS"; };
    pkdjz = { flake = false; url = "path:./nix/pkdjz"; };
    homeModule = { flake = false; url = "path:./nix/homeModule"; };
    neksysNames = { flake = false; url = "path:./nix/neksysNames"; };
    tests = { url = "path:./nix/tests"; flake = false; };
    mkKriomDatom = { url = "path:./nix/mkKriomDatom"; flake = false; };
    files = { url = "path:./nix/files"; flake = false; };
    AskiCoreNiks = { url = "path:./AskiCoreNiks"; flake = false; };
    AskiNiks = { url = "path:./AskiNiks"; flake = false; };
    AskiDefaultBuilder = { url = "path:./AskiDefaultBuilder"; flake = false; };
  };

  outputs = inputs@{ self, ... }:
    let
      kriomOSRev =
        let shortHash = kor.cortHacString self.narHash;
        in self.shortRev or shortHash;

      localHobSources = {
        inherit (inputs) AskiCoreNiks AskiNiks AskiDefaultBuilder
          xdg-desktop-portal-hyprland mkWebpage;
        pkdjz = { HobUyrldz = import inputs.pkdjz; };
      };

      importInput = name: value:
        import value;

      hob = inputs.hob.value // localHobSources;

      inherit (hob) flake-utils emacs-overlay nixpkgs lib;
      
      imports = mapAttrs importInput {
        inherit (inputs) kor mkPkgs mkKriosfir mkKriozonz mkKriomOS
          mkHomeConfig neksysNames mkUyrld homeModule files;
      };

      inherit (imports) kor neksysNames mkPkgs homeModule mkKriomOS mkUyrld;

      mkPkgsAndUyrldFromSystem = system:
        let
          pkgs =
            let
              overlays = [ emacs-overlay.overlay ];
            in
            mkPkgs { inherit nixpkgs lib system overlays; };
          uyrld = mkUyrld { inherit lib pkgs system hob imports; };
        in
        { inherit pkgs uyrld; };

      perSystemPkgsAndUyrld = eachDefaultSystem mkPkgsAndUyrldFromSystem;

      mkPkgsAndUyrld = system:
        mapAttrs (name: value: value.${system}) perSystemPkgsAndUyrld;

      mkDatom = import inputs.mkDatom { inherit kor lib; };
      mkKriomDatom = import inputs.mkKriomDatom { inherit kor lib mkDatom; };

      inherit (builtins) fold attrNames mapAttrs filterAttrs;
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
          os = mkKriomOS
            { inherit kriomOSRev kor uyrld hyraizyn homeModule hob; };
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
            KRIOMOSBOOTFILE = self + /boot.shen;
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
      outputs = Kriom.mkOutputs { inherit mkKriomOS kriomOSRev mkPkgsAndUyrld homeModule; };
    };
}
