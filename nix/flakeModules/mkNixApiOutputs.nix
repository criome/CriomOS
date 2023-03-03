{ pkgs, lib, config, pkdjz, ... }:
let
  inherit (pkgs) symlinkJoin linkFarm;
  inherit (pkdjz) shen-ecl-bootstrap;
  shen = shen-ecl-bootstrap;

  devShell = pkgs.mkShell {
    inputsFrom = [ ];
    KRIOMOSBOOTFILE = self + /boot.shen;
    buildInputs = [ shen ];
  };

  mkHobOutput = name: src:
    symlinkJoin { inherit name; paths = [ src.outPath ]; };

  hobOutputs = mapAttrs mkHobOutput hob;

  mkSpokFarmEntry = name: spok:
    { inherit name; path = spok.outPath; };

  allMeinHobOutputs = linkFarm "hob"
    (kor.mapAttrsToList mkSpokFarmEntry hobOutputs);

  packages = {
    inherit pkgs;
    hob = hobOutputs;
    fullHob = allMeinHobOutputs;
  };

  tests = import inputs.tests { inherit lib mkDatom; };

in
{ inherit tests packages devShell; }
