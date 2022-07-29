{ kor, lib }:

{ typeModule
, methods ? { }
, extraTypecheckingModule ? { }
, extraModuleArgs ? { }
}@spec:

inputs:

let
  inherit (kor) mkLamdyz;
  inherit (lib) evalModules submodule;

  argsModule = { config._module.args = extraModuleArgs // { inherit lib; }; };

  typeCheckingModule = { ... }: {
    options.inputs = mkOption { type = (submodule typeModule); };
    config.inputs = inputs;
  };

  typeCheckingEvaluation = evalModules {
    modules = [ argsModule typeCheckingModule extraTypecheckingModule ];
  };

  Datom = typeCheckingEvaluation.config.inputs;

  closure = Datom // { inherit kor lib; };

  methods = mkLamdyz { klozyr = closure; lamdyz = spec.methods; };

in
methods // { inherit Datom; }
