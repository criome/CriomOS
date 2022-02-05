{ pkgs
, lib
, rust
, buildRustCrate
, defaultCrateOverrides
, kreitOvyraidz
, nightlyRust
}@argz:

{ cargoNix
, nightly ? false
, crateOverrides ? { }
,
}@yrgz:

let
  defaultCrateOverrides = argz.defaultCrateOverrides
    // kreitOvyraidz // crateOverrides;

  buildRustCrateForPkgs = pkgs:
    if nightly
    then argz.buildRustCrate.override { rustc = nightlyRust.rust; }
    else argz.buildRustCrate;

in
cargoNix
  { inherit lib pkgs defaultCrateOverrides; }
  // (optionalAttrs nightly
  { inherit buildRustCrateForPkgs; })
