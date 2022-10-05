{ config, kor, lib, ... }:
let
  inherit (builtins) attrNames attrValues;
  inherit (kor) arkSistymMap;
  inherit (lib) mkOption listToAttrs nameValuePair;
  inherit (lib.types) enum str attrsOf submodule nullOr bool int
    listOf attrs;
  inherit (config) PriMetastriz;

  magnytiud = [ 0 1 2 3 ];

  mycinArkz = attrNames arkSistymMap;
  sistymz = attrValues arkSistymMap;

  butlodyrz = [ "uefi" "mbr" "uboot" ];
  kibordz = [ "qwerty" "colemak" ];

  astriSpiciz = [ "sentyr" "haibrid" "edj" ];

  metastriNeimz = attrNames PriMetastriz;

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

  AstriPriKriomSpici = submodule {
    options = {
      eseseitc = mkOption {
        type = nullOr str;
        default = null;
      };

      yggdrasil = {
        priKriom = mkOption {
          type = nullOr str;
          default = null;
        };

        address = mkOption {
          type = nullOr str;
          default = null;
        };

        subnet = mkOption {
          type = nullOr str;
          default = null;
        };
      };

      niksPriKriom = mkOption {
        type = nullOr str;
        default = null;
      };
    };
  };

  astriSubmodule = ({ name, config, ... }:
    let
      preNexus = { };
    in
    {
      options = {
        spici = mkOption {
          type = enum astriSpiciz;
          default = "sentyr";
        };

        saiz = mkOption {
          type = enum magnytiud;
          default = 0;
        };

        trost = mkOption {
          type = enum magnytiud;
          default = 1;
        };

        mycin = mkOption {
          type = mycinSpici;
        };

        io = mkOption {
          type = submodule { options = IoOptions; };
          default = { };
        };

        priKriomz = mkOption {
          type = AstriPriKriomSpici;
          default = { };
        };

        linkLocalIPs = mkOption {
          type = listOf attrs;
          default = [ ];
        };

        neksysIp = mkOption {
          type = nullOr str;
          default = null;
        };

        wireguardPriKriom = mkOption {
          type = nullOr str;
          default = null;
        };

      };
    });


  defaultTrost = 1;

  mkDefaultTrostFromNeimz = neimz: listToAttrs
    (map (n: nameValuePair n defaultTrost))
    neimz;

  trostSubmodule = {
    options = {
      metastra = mkOption {
        type = enum magnytiud;
        default = 1;
      };

      metastriz = mkOption {
        type = attrsOf (enum magnytiud);
      };

      astriz = mkOption {
        type = attrsOf (enum magnytiud);
      };

      krimynz = mkOption {
        type = attrsOf (enum magnytiud);
      };
    };
  };

  domeinSubmodule = {
    options = {
      spici = mkOption {
        type = enum [ "cloudflare" ];
        default = "cloudflare";
      };
    };
  };

  krimynSubmodule = {
    options = komynKrimynOptions;
  };

  metastriSubmodule = {
    options = {
      astriz = mkOption {
        type = attrsOf (submodule astriSubmodule);
        default = {
          priKriomz = { };
        };
      };

      krimynz = mkOption {
        type = attrsOf (submodule krimynSubmodule);
      };

      domeinz = mkOption {
        type = attrsOf (submodule domeinSubmodule);
        default = { };
      };

      trost = mkOption {
        type = submodule trostSubmodule;
      };
    };
  };

in
{
  options = {
    subKrioms = mkOption {
      type = attrsOf (submodule metastriSubmodule);
    };
  };
}
