{ kor, system, aski, uniks, writeText }:
let
  inherit (kor) mesydj mkImplicitVersion;
in
inputs@
{ name
, src
, askiUniks ? null
, version ? mkImplicitVersion src
, nixInputs ? { }
}:
let
  inherit (builtins) pathExists concatStringsSep;
  name = concatStringsSep "-" [ inputs.name version ];
  uniksLib = uniks.core + /lib.aski;
  uniksBuilder = uniks.core + /builder.aski;

  implicitBuildFile =
    let
      filePath = src + /uniks.aski;
      fileExists = pathExists filePath;
    in
    assert mesydj fileExists
      "Uniks file missing: ${filePath}";
    filePath;

  uniksBuildFile =
    if (askiUniks != null)
    then askiUniks
    else implicitBuildFile;

  askiDeryveicyn = writeText "deryveicyn.aski" ''
    (load "${uniksLib}")
    (load "${uniksBuilder}")
  '';

in
derivation {
  inherit name system src uniksBuildFile nixInputs;
  builder = aski.current + /bin/aski;
  args = [ askiDeryveicyn ];
  __structuredAttrs = true;
}
