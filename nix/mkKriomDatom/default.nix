{ mkDatom, lib }: inputs:
let
  types = {
    kriozonz = mkOption {
      type = attrsOf (submodule metastriSubmodule);
    };
  };

  methods = {
    mkOutputs = { kriozonz }: { };
  };

in
mkDatom { inherit types methods; } inputs
