{ hyraizyn, config, kor, pkgs, ... }:
let
  inherit (builtins) filter mapAttrs attrNames hasAttr
    concatStringsSep concatMap;
  inherit (kor) optionals optional optionalString mkIf optionalAttrs;

  inherit (hyraizyn) astra exAstriz krimynz;
  inherit (astra.spinyrz) adminEseseitcPriKriomz;

  krimynNeimz = attrNames krimynz;

  mkEseseitcString = priKriom: concatStringsSep " "
    [ "ed25519" priKriom.eseseitc ];

  mkKrimyn = attrNeim: krimyn:
    let
      inherit (krimyn) trost spinyrz;
      inherit (krimyn.spinyrz) eseseitcyz hazPriKriom;

    in
    optionalAttrs (trost > 0) {
      name = krimyn.neim;

      useDefaultShell = true;
      isNormalUser = true;

      openssh.authorizedKeys.keys = eseseitcyz;

      extraGroups = [ "audio" ]
        ++
        (optional (config.programs.sway.enable == true) "sway")
        ++
        (optionals (trost >=2)
          ([ "video" ] ++
            (optional (config.networking.networkmanager.enable == true)) "networkmanager"))
        ++
        (optionals (trost >= 3) [
          "adbusers"
          "nixdev"
          "systemd-journal"
          "dialout"
          "plugdev"
          "storage"
          "libvirtd"
        ]);
    };

  mkKrimynUsers = mapAttrs mkKrimyn krimynz;


  rootUserAkses = {
    root = {
      openssh.authorizedKeys.keys = adminEseseitcPriKriomz;
    };
  };

in
{ users = { users = mkKrimynUsers // rootUserAkses; }; }
