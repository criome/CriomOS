{ config, kor, lib, ... }:
let
  inherit (builtins) attrNames attrValues;
  inherit (kor) arkSistymMap;
  inherit (lib) mkOption listToAttrs nameValuePair;
  inherit (lib.types) enum str attrsOf submodule nullOr bool int
    listOf attrs;

  magnitude = [ 0 1 2 3 ];

  mycinArkz = attrNames arkSistymMap;
  sistymz = attrValues arkSistymMap;

  butlodyrz = [ "uefi" "mbr" "uboot" ];
  keyboardTypes = [ "qwerty" "colemak" ];

  nodeTypes = [ "center" "hybrid" "edge" ];

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
      type = enum magnitude;
      default = 0;
    };

    type = mkOption {
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
      type = mkOption {
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

      ubyrNode = mkOption {
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
      type = enum keyboardTypes;
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

  nodePriKriomSpici = submodule {
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

  nodeSubmodule = ({ name, config, ... }:
    let
      preNexus = { };
    in
    {
      options = {
        type = mkOption {
          type = enum nodeTypes;
          default = "center";
        };

        saiz = mkOption {
          type = enum magnitude;
          default = 0;
        };

        trost = mkOption {
          type = enum magnitude;
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
          type = nodePriKriomSpici;
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
      subKrioms = mkOption {
        type = attrsOf (enum magnitude);
      };

      nodes = mkOption {
        type = attrsOf (enum magnitude);
      };

      krimynz = mkOption {
        type = attrsOf (enum magnitude);
      };
    };
  };

  domeinSubmodule = {
    options = {
      type = mkOption {
        type = enum [ "cloudflare" ];
        default = "cloudflare";
      };
    };
  };

  krimynSubmodule = {
    options = komynKrimynOptions;
  };

  subKriomSubmodule = {
    options = {
      nodes = mkOption {
        type = attrsOf (submodule nodeSubmodule);
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
      type = attrsOf (submodule subKriomSubmodule);
    };
  };
}
