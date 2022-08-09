{ mkDatom, kor, lib }: inputKriom:
let
  typeModule = import ./typeModule.nix;

  methods = {
    mkOutputs = import ./mkOutputs.nix;
  };

in
mkDatom { inherit typeModule methods; } inputKriom
