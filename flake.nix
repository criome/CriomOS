{
  description = "Uniks";

  inputs = {
    hob.url = github:sajban/hob;

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
  };

  outputs = inputs@{ self, hob, ... }:
    let
      # (hak directInputsImports)
      hob = inputs.hob.Hob;
      nixpkgs = hob.nixpkgs.mein;
      flake-utils = hob.flake-utils.mein;
      emacs-overlay = hob.emacs-overlay.mein;

      AskiUniksSources = {
        inherit (inputs) AskiCoreUniks AskiUniks AskiDefaultBuilder;
      };

      kor = import ./nix/kor.nix;
      mkKriosfir = import ./nix/mkKriosfir;
      mkKriozonz = import ./nix/mkKriozonz;
      mkUniksOS = import ./nix/mkUniksOS;
      mkHom = import ./nix/mkHom;
      neksysProposalHobSpokNames = import ./neksysProposalHobSpokNames.nix;

      inherit (builtins) fold attrNames mapAttrs;
      inherit (nixpkgs) lib;
      inherit (kor) mkLamdy arkSistymMap genAttrs;
      inherit (flake-utils.lib) eachDefaultSystem;

      generateKriosfirProposalFromName = name:
        hob."${name}".mein.NeksysProposal;

      uncheckedKriosfirProposal = genAttrs
        neksysProposalHobSpokNames
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
          mkUyrld = import ./nix/mkUyrld.nix;
          uyrld = mkUyrld { inherit pkgs kor lib system hob AskiUniksSources; };
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
            hob = hobOutputs // { mein = allMeinHobOutputs; };
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
