{ kor, lib }:

{ typeModule
, methods ? { }
, extraTypecheckingModule ? { }
, extraModuleArgs ? { }
}@spec:

datom:

let
  inherit (kor) mkLamdyz;
  inherit (lib) evalModules submodule mkOption;

  argsModule = { config._module.args = extraModuleArgs // { inherit lib; }; };

  typeCheckingModule = { ... }: {
    options.datom = mkOption { type = (submodule typeModule); };
    config.datom = datom;
  };

  typeCheckingEvaluation = evalModules {
    modules = [ argsModule typeCheckingModule extraTypecheckingModule ];
  };

  Datom = typeCheckingEvaluation.config.datom;

  closure = Datom // { inherit kor lib; };

  methods = mkLamdyz { klozyr = closure; lamdyz = spec.methods; };

in
methods // { inherit Datom; }
