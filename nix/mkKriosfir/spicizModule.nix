{ kor, lib, config, priMetastriz, ... }:
let
  inherit (builtins) attrNames attrValues;
  inherit (kor) arkSistymMap;
  inherit (lib) mkOption;
  inherit (lib.types) enum str attrsOf submodule nullOr bool int
    listOf attrs;

  magnytiud = [ 0 1 2 3 ];

  mycinArkz = attrNames arkSistymMap;
  sistymz = attrValues arkSistymMap;

  butlodyrz = [ "uefi" "mbr" "uboot" ];
  kibordz = [ "qwerty" "colemak" ];

  astriSpiciz = [ "sentyr" "haibrid" "edj" "edjTesting" "mediaBroadcast" "router" ];

  metastriNeimz = attrNames priMetastriz;

  priKriomSubmodule = {
    options = {
      eseseitc = mkOption {
        type = str;
      };

      keygrip = mkOption {
        type = str;
      };
    };
  };

  komynKrimynOptions = {
    saiz = mkOption {
      type = enum magnytiud;
      default = 0;
    };

    spici = mkOption {
      type = enum [ "Niks" "Sema" "Onlimityd" ];
      default = "Sema";
    };

    stail = mkOption {
      type = enum [ "vim" "emacs" ];
      default = "emacs";
    };

    priKriomz = mkOption {
      type = attrsOf (submodule priKriomSubmodule);
    };

    kibord = mkOption {
      type = enum [ "colemak" "qwerty" ];
      default = "colemak";
    };

    githubId = mkOption {
      type = nullOr str;
      default = null;
    };

  };

  mycinSpici = submodule {
    options = {
      spici = mkOption {
        type = enum [ "metyl" "pod" ];
        default = "metyl";
      };

      ark = mkOption {
        type = nullOr (enum mycinArkz);
        default = null;
      };

      korz = mkOption {
        type = int;
        default = 1;
      };

      modyl = mkOption {
        type = nullOr str;
        default = null;
      };

      mothyrBord = mkOption {
        type = nullOr (enum mothyrBordSpiciNeimz);
        default = null;
      };

      ubyrAstri = mkOption {
        type = nullOr str;
        default = null;
      };

      ubyrKrimyn = mkOption {
        type = nullOr str;
        default = null;
      };
    };
  };

  IoOptions = {
    kibord = mkOption {
      type = enum kibordz;
      default = "colemak";
    };

    butlodyr = mkOption {
      type = enum butlodyrz;
      default = "uefi";
    };

    disks = mkOption {
      type = attrs;
      default = { };
    };

    swapDevices = mkOption {
      type = listOf attrs;
      default = [ ];
    };
  };

  mothyrBordSpiciNeimz = [ "ondyfaind" ];

in
{
  options = {
    spiciz = mkOption {
      type = attrs;
      default = { };
    };
  };

  config.spiciz = {
    inherit komynKrimynOptions IoOptions mycinSpici kibordz butlodyrz magnytiud
      metastriNeimz astriSpiciz sistymz;
  };

}
