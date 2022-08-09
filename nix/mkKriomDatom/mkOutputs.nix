{ kor, lib, kriozonz, mkOutputsOfSystem, krioniksRev }:

let
  inherit (builtins) fold attrNames mapAttrs filterAttrs;

  mkNeksysDerivations = priNeksysNeim: kriozon:
    let
      inherit (kriozon) krimynz;
      inherit (kriozon.astra.mycin) ark;
      system = kor.arkSistymMap.${ark};
      outputsOfSystem = mkOutputsOfSystem system;
      inherit (outputsOfSystem) pkgs uyrld nextPkgs;
      hyraizyn = kriozon;

      krimynProfiles = {
        light = { dark = false; };
        dark = { dark = true; };
      };

      mkKrimynHomz = krimynNeim: krimyn:
        let
          emacsPkgs = uyrld.pkdjz.meikPkgs
            { overlays = [ uyrld.emacs-overlay.overlay ]; };
          pkgs =
            if (krimyn.stail == "emacs")
            then emacsPkgs
            else outputsOfSystem.pkgs;
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
      os = mkKrioniks { inherit krioniksRev nixpkgs kor uyrld hyraizyn; };
      hom = mapAttrs mkKrimynHomz krimynz;
      imaks = mapAttrs mkKrimynImaks krimynz;
    };

  mkNeksysDerivationIndex = neksysNeim: neksysPrineksysIndeks:
    mapAttrs mkNeksysDerivations neksysPrineksysIndeks;

in
mapAttrs mkNeksysDerivationIndex kriozonz
