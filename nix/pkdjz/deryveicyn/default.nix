{ kor, system, aski, AskiCoreNiks, AskiNiks, AskiDefaultBuilder, writeText }:
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

  niksBuildFile =
    if (askiFleik != null)
    then askiFleik
    else implicitBuildFile;

  askiDeryveicyn = writeText "deryveicyn.aski" ''
    (load "${AskiCoreNiks + /lib.aski}")
    (load "${AskiDefaultBuilder + /builder.aski}")
  '';

in
derivation {
  inherit name system src niksBuildFile nixInputs;
  builder = aski.current + /bin/aski;
  args = [ askiDeryveicyn ];
  __structuredAttrs = true;
}
