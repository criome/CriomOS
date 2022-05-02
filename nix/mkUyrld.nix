{ kor, pkgs, lib, hob, system, neksysNames, bootstrapUyrld, nextUyrld }:
let
  inherit (builtins) hasAttr mapAttrs concatStringsSep elem;
  inherit (uyrld) pkdjz;

  meikSobUyrld = SobUyrld@{ lamdy, modz, self, src ? self, sobUyrldz ? { } }:
    let
      inherit (builtins) getAttr elem;
      inherit (kor) mkLamdy optionalAttrs genAttrs;

      Modz = [
        "lib"
        "pkgs"
        "pkgsStatic"
        "pkgsSet"
        "hob"
        "pkdjz"
        "uyrld"
        "uyrldSet"
        "bootstrapUyrld"
        "nextUyrld"
      ];

      iuzMod = genAttrs Modz (n: (elem n modz));

      /* Warning: sets shadowing */
      klozyr = optionalAttrs iuzMod.pkgs pkgs
        // optionalAttrs iuzMod.pkgsStatic pkgs.pkgsStatic
        // optionalAttrs iuzMod.uyrld uyrld
        // optionalAttrs iuzMod.pkdjz pkdjz
        // optionalAttrs iuzMod.hob { inherit hob; }
        // optionalAttrs iuzMod.lib { inherit lib; }
        // optionalAttrs iuzMod.pkgsSet { inherit pkgs; }
        // optionalAttrs iuzMod.uyrldSet { inherit uyrld; }
        // optionalAttrs iuzMod.bootstrapUyrld { inherit bootstrapUyrld; }
        // optionalAttrs iuzMod.nextUyrld { inherit nextUyrld; }
        // sobUyrldz
        // { inherit kor; }
        // { inherit system; }
        # TODO: deprecate `self` for `src`
        // { inherit self; }
        // { src = self; };

    in
    mkLamdy { inherit klozyr lamdy; };

  meikFleik = spokNeim: fleik@{ ... }:
    let
      priMeikSobUyrld = neim: SobUyrld@{ modz ? [ ], lamdy, ... }:
        let
          src = SobUyrld.src or (SobUyrld.self or fleik);
          self = SobUyrld.self or fleik;
        in
        meikSobUyrld { inherit src self modz lamdy; };

      priMeikHobUyrld = neim: HobUyrld@{ modz ? [ ], lamdy, ... }:
        let
          implaidSelf = hob.${neim}.mein or null;
          src = HobUyrld.src or (HobUyrld.self or implaidSelf);
          self = src;
        in
        meikSobUyrld { inherit src self modz lamdy; };

      meikHobUyrldz = HobUyrldz:
        let
          priHobUyrldz = HobUyrldz hob;
        in
        mapAttrs priMeikHobUyrld priHobUyrldz;

      meikSobUyrldz = SobUyrldz:
        let
          priMeikSobUyrldz = neim: SobUyrld@{ modz ? [ ], lamdy, ... }:
            let
              src = SobUyrld.src or (SobUyrld.self or fleik);
              self = src;
            in
            meikSobUyrld { inherit src self modz lamdy sobUyrldz; };

          sobUyrldz = mapAttrs priMeikSobUyrldz SobUyrldz;
        in
        sobUyrldz;

      mkNeksysWebpageName = neksysNeim:
        concatStringsSep "-" [ "page" neksysNeim "uniks" ];

      neksysWebpageSpokNames = map mkNeksysWebpageName neksysNames;

      isWebpageSpok = spokNeim:
        elem spokNeim neksysWebpageSpokNames;

      mkWebpageFleik = Webpage@{ content ? fleik, ... }:
        let
          SobUyrld = {
            self = null;
            modz = [ "pkdjz" ];
            lamdy = { mkWebpage }:
              mkWebpage Webpage;
          };
        in
        meikSobUyrld SobUyrld;

      fleikHasDefaultPackage = hasAttr "defaultPackage" fleik
        && hasAttr system fleik.defaultPackage;

    in
    if (hasAttr "HobUyrldz" fleik)
    then meikHobUyrldz fleik.HobUyrldz
    else if (hasAttr "HobUyrld" fleik)
    then priMeikHobUyrld spokNeim (fleik.HobUyrld hob)
    else if (hasAttr "SobUyrldz" fleik)
    then meikSobUyrldz fleik.SobUyrldz
    else if (hasAttr "SobUyrld" fleik)
    then priMeikSobUyrld spokNeim fleik.SobUyrld
    else if (hasAttr "Webpage" fleik)
    then mkWebpageFleik fleik.Webpage
    else if (isWebpageSpok spokNeim)
    then mkWebpageFleik { content = fleik; }
    else if fleikHasDefaultPackage
    then fleik.defaultPackage.${system}
    else fleik;

  meikSpok = spokNeim: spok:
    meikFleik spokNeim spok.mein;

  uniksSpoks = {
    pkdjz.mein = { HobUyrldz = (import ./pkdjz); };
  };

  spoks = hob // uniksSpoks;

  uyrld = mapAttrs meikSpok spoks;

in
uyrld
