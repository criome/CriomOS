{ kor, system, aski, hob, writeText }:
let
  inherit (kor) mesydj mkImplicitVersion;
in
inputs@
{ name
, src
, askiFleik ? null
, version ? mkImplicitVersion src
, nixInputs ? { }
}:
let
  inherit (builtins) pathExists concatStringsSep;
  inherit (hob) AskiCoreUniks AskiUniks AskiDefaultBuilder;
  name = concatStringsSep "-" [ inputs.name version ];

  implicitBuildFile =
    let
      fleikPath = src + /fleik.aski;
      legacyFilePath = src + /flake.aski;
      fleikExists = (pathExists fleikPath);
      fileExists = fleikExists || (pathExists legacyFilePath);
      result =
        if fleikExists then fleikPath
        else legacyFilePath;

    in
    assert mesydj fileExists
      "Aski fleik missing: ${fleikPath}";
    result;

  uniksBuildFile =
    if (askiFleik != null)
    then askiFleik
    else implicitBuildFile;

  askiDeryveicyn = writeText "deryveicyn.aski" ''
    (load "${AskiCoreUniks + /lib.aski}")
    (load "${AskiDefaultBuilder + /builder.aski}")
  '';

in
derivation {
  inherit name system src uniksBuildFile nixInputs;
  builder = aski.current + /bin/aski;
  args = [ askiDeryveicyn ];
  __structuredAttrs = true;
}
