{ kor, lib }:

{ name
, typeModule
, topLevelType ? lib.attrsOf
, typeModuleExtraArgs ? { }
, methods ? { }
, extraModuleArgs ? { }
}@spec:

datom:

let
  inherit (kor) mkLamdyz;
  inherit (lib) evalModules mkOption;
  inherit (lib.types) submoduleWith;

  argsModule = { _module.args = extraModuleArgs // { inherit lib; }; };

  typeModuleArgs =
    { _module.args = typeModuleExtraArgs // { inherit name kor; }; };

  typeSubmodule = submoduleWith {
    shorthandOnlyDefinesConfig = true;
    modules = [ spec.typeModule typeModuleArgs ];
  };

  typeCheckingModule = { lib, ... }: with lib; {
    options.datom = mkOption { type = typeSubmodule; };
  };

  typeCheckingEvaluation = evalModules
    { modules = [ argsModule typeCheckingModule { inherit datom; } ]; };

  Datom = typeCheckingEvaluation.config.datom;

  closure = Datom // { inherit kor lib; };

  methods = mkLamdyz { klozyr = closure; lamdyz = spec.methods; };

in
methods // { inherit name Datom; }
