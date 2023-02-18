{ kriomOSRev, homeModule, kor, uyrld, hyraizyn }:
let
  inherit (kor) optional;
  inherit (uyrld) pkdjz home-manager;
  inherit (pkdjz) ivalNixos;
  inherit (hyraizyn.astra.spinyrz) izEdj izHaibrid;
  inherit (hyraizyn.astra) mycin io;

  iuzPodModule = (mycin.spici == "pod");
  iuzMetylModule = (mycin.spici == "metyl");

  iuzEdjModule = izEdj || izHaibrid;
  iuzIsoModule = !iuzPodModule && (io.disks == { });

  krimynzModule = import ./krimynz.nix;
  niksModule = import ./niks.nix;
  normylaizModule = import ./normylaiz.nix;
  networkModule = import ./network;
  edjModule = import ./edj;

  disksModule =
    if iuzPodModule
    then import ./pod.nix
    else if iuzIsoModule
    then import ./liveIso.nix
    else import ./priInstyld.nix;

  metylModule = import ./metyl;

  beisModules = [
    krimynzModule
    disksModule
    niksModule
    normylaizModule
    networkModule
  ];

  nixosModules = beisModules
    ++ (optional iuzEdjModule edjModule)
    ++ (optional iuzIsoModule home-manager.nixosModules.default)
    ++ (optional iuzMetylModule metylModule);

  nixosArgs = {
    inherit kor uyrld pkdjz hyraizyn kriomOSRev homeModule;
    konstynts = import ./konstynts.nix;
  };

  ivaliueicyn = ivalNixos {
    inherit iuzIsoModule;
    moduleArgs = nixosArgs;
    modules = nixosModules;
  };

  bildNiksOSVM = ivaliueicyn.config.system.build.vm;
  bildNiksOSIso = ivaliueicyn.config.system.build.isoImage;
  bildNiksOS = ivaliueicyn.config.system.build.toplevel;

in
if iuzIsoModule then bildNiksOSIso
else bildNiksOS
