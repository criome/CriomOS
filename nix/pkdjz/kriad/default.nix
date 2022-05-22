{ kor, src, writeText, stdenv, shen, shenPrelude, deryveicyn, asdf, buildEnv }:
let
  inherit (kor) mkImplicitVersion;

  uiopEntryFile = asdf + /lib/common-lisp/uiop/driver.lisp;

  uiopShen = writeText "uiop.shen" ''
    (shen-cl.load-lisp "${uiopEntryFile}")
  '';

  libSuffixPath = "/lib/shen/lib.shen";

  bootstrapNiksLib = stdenv.mkDerivation {
    pname = "bootstrapNiksLib";
    version = mkImplicitVersion src;
    inherit src;

    buildInputs = [ asdf ];

    phases = [ "unpackPhase" "installPhase" ];

    installPhase = ''
      mkdir -p $out/lib/shen
      cp -r ./*.shen $out/lib/shen/
      rm $out/lib/shen/fleik.shen
      ln -s ${uiopShen} $out/lib/shen/uiop.shen
    '';
  };

  niksEnv = buildEnv {
    name = "niksEnv";
    paths = [ niksLib ];
  };

  niksLib = deryveicyn {
    name = "niksLib";
    niksLib = bootstrapNiksLib;
    inherit src;
    nixInputs = { inherit asdf; };
  };

in
{ inherit niksLib niksEnv libSuffixPath; }
