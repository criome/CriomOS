{ kor
, stdenv
, sbcl
, writeText
, deryveicyn
, KLambdaBootstrap
, LispCore
, LispCorePrimitives
, LispExtendedPrimitives
, ShenAski
, ShenCoreBootstrap
, ShenCore
, ShenCoreTests
, ShenExtendedBootstrap
, ShenExtended
, ShenExtendedTests
, AskiCore
, AskiCoreFleik
}@inputs:
let
  inherit (builtins) concatStringsSep readFile mapAttrs;

  mkAski =
    { src
    , version ? kor.mkImplicitVersion src
    , corePrimitives ? (LispCorePrimitives + /primitives.lsp)
    , extendedPrimitives ? (LispExtendedPrimitives + /primitives.lsp)
    , lispMakeCore ? (LispCore + /make.lsp)
    , lispBackend ? (LispCore + /backend.lsp)
    , ShenCoreTests ? inputs.ShenCoreTests
    , ShenExtendedTests ? inputs.ShenExtendedTests
    }:
    let
      lispPrimitives = writeText "allPrimitives.lsp"
        (concatStringsSep "\n" [
          (readFile corePrimitives)
          (readFile extendedPrimitives)
        ]);

      lispMakeExtension = ''
        (LOAD "${sbcl}/lib/sbcl/contrib/uiop.fasl")
      '';

      lispMakeExtended = writeText "make.lsp"
        (builtins.concatStringsSep "\n"
          [ lispMakeExtension (readFile lispMakeCore) ]);

      lispMake = lispMakeExtended;

      ShenLoadTests = writeText "make.lsp"
        ''
          (cd ${ShenCoreTests})
          (load "runme.shen")
          (cd ${ShenExtendedTests})
          (load "init.shen")
        '';

    in
    stdenv.mkDerivation {
      pname = "aski";
      inherit version src;
      postPatch = ''
        mkdir KLambda
        mv ./*.kl ./KLambda/
        ln -s ${lispPrimitives} ./primitives.lsp
        ln -s ${lispBackend} ./backend.lsp
      '';
      buildInputs = [ sbcl ];
      buildPhase = ''
        sbcl --load ${lispMake}
      '';
      installPhase = ''
        install -m755 -D ./aski $out/bin/aski
      '';
      dontStrip = true; # (blockedBy staticLinking)
      doCheck = true;
      checkPhase = ''
        ./aski ${ShenLoadTests}
      '';
    };

  mkAskiNext = { src, version, askiFleik ? (AskiCoreFleik + /fleik.aski) }:
    deryveicyn {
      name = "aski";
      inherit src version askiFleik;
      nixInputs = {
        inherit sbcl ShenAski ShenCoreTests ShenExtendedTests
          LispCorePrimitives LispExtendedPrimitives;
      };
    };

  mkKLambda =
    { src
    , extendedSrc ? ShenExtended
    , withBootstrap ? false
    , version ? kor.mkImplicitVersion src
    , shenMakeKLambda ? (ShenCoreBootstrap + /makeKLambda.shen)
    , shenMakeExtendedKLambda ? (ShenExtendedBootstrap + /makeKLambda.shen)
    }:
    let
      askiExecutable =
        if withBootstrap then aski.bootstrap
        else aski.current;

    in
    stdenv.mkDerivation {
      pname = "klambda";
      inherit version src;
      buildInputs = [ askiExecutable ];
      patchPhase = ''
        cp ${extendedSrc}/*.shen ./
      '';
      buildPhase = ''
        aski ${shenMakeKLambda}
        aski ${shenMakeExtendedKLambda}
      '';
      installPhase = ''
        mkdir $out
        install -m644 -D ./*.kl $out
      '';
      doCheck = false;
    };

  currentVersion = "alphaPrime";
  nextVersion = "alphaSecond";

  bootstrap = mkAski { src = KLambdaBootstrap; };

  currentKLambda = mkKLambda {
    src = ShenCore;
    extendedSrc = ShenExtended;
    version = currentVersion;
    withBootstrap = true;
  };

  current = mkAski {
    src = currentKLambda;
    version = currentVersion;
  };

  nextKLambda =
    mkKLambda {
      src = ShenCore;
      version = nextVersion;
    };

  next = mkAskiNext {
    src = nextKLambda;
    version = nextVersion;
  };

in
{ inherit bootstrap current next; }
