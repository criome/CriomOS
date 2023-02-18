{ kor, lib, self }:
{ mkKriomOS, mkPkgsAndUyrld, kriomOSRev, homeModule }:

let
  inherit (self) subKrioms;
  inherit (builtins) fold attrNames mapAttrs filterAttrs;

  mkNodeDerivations = subKriomName: nodeName: node:
    let
      hyraizyn = node;

      inherit (node) krimynz;
      inherit (node.astra.mycin) ark;
      system = kor.arkSistymMap.${ark};
      pkgsAndUyrld = mkPkgsAndUyrld system;
      inherit (pkgsAndUyrld) pkgs uyrld;

      krimynProfiles = {
        light = { dark = false; };
        dark = { dark = true; };
      };

      mkKrimynHomz = krimynNeim: krimyn:
        let
          mkProfileHom = profileName: profile:
            let
              homeConfig = uyrld.mkHomeConfig
                { inherit hyraizyn krimyn profile; };
            in
            homeConfig.home.activationPackage;
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
      os = mkKriomOS { inherit kriomOSRev kor uyrld hyraizyn homeModule; };
      hom = mapAttrs mkKrimynHomz krimynz;
      imaks = mapAttrs mkKrimynImaks krimynz;
    };

  mkSubKriomDerivations = subKriomName: nodes:
    let
      primedMkNodeDerivations = mkNodeDerivations subKriomName;
    in
    mapAttrs mkNodeDerivations nodes;

in
mapAttrs mkSubKriomDerivations subKrioms
