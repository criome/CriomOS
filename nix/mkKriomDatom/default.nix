{ mkDatom, kor, lib }: inputKriom:
let
  typeModule = import ./typeModule.nix;

  methods = {
    mkOutputs = { kriozonz }: { };
  };

  extraModuleArgs = { inherit kor; };

in
mkDatom { inherit typeModule methods extraModuleArgs; } inputKriom
