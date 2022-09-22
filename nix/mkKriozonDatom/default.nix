{ mkDatom, kor, lib }: kriozonDataInput:
let
  name = "kriozon";

  typeModule = import ./typeModule.nix;

  methods = {
    mkOutputs = import ./mkOutputs.nix;
  };

in
mkDatom { inherit name typeModule methods; } kriozonDataInput
