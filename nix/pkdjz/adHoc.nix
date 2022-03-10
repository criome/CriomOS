hob:
let
  inherit (builtins) mapAttrs;

in
{
  reseter-css = {
    modz = [ "pkgs" ];
    lamdy = { src, stdenv }:
      let
      in
      stdenv.mkDerivation {
        name = "reseter.css";
        inherit src;
        phases = [ "unpackPhase" "installPhase" ];
        installPhase = ''
          mkdir -p $out/lib
          cp -R ./css $out/lib
          cp -R ./src/* $out/lib
        '';
        passthru = {
          scssLib = "/lib/scss/reseter.scss";
        };
      };
  };

  firn = {
    modz = [ "pkdjz" ];
    lamdy = { src, mkCargoNix, }:
      let
        cargoNixRyzylt = mkCargoNix {
          cargoNix = import (src + /Cargo.nix);
        };
      in
      cargoNixRyzylt.workspaceMembers.firn.build;
  };

  jumpdrive = {
    modz = [ "pkgs" "pkdjz" ];
    src = null;
    lamdy = { stdenv, fetchurl, mksh, writeScriptBin, mfgtools }:
      let
        mkRelease = name: versionAndNarHashes:
          let
            inherit (versionAndNarHashes) version narHash;

            url =
              "https://github.com/dreemurrs-embedded/Jumpdrive/releases/download/${version}/${name}.tar.xz";

            src = fetchurl { inherit url; hash = narHash; };

            launcherName = "jumpdrive-" + name;
            dataDirectorySuffix = "/share/jumpdrive/${name}";

            dataPkgName = name + "-data";

            dataPkg = stdenv.mkDerivation
              {
                name = dataPkgName;
                inherit src;
                phases = [ "unpackPhase" "installPhase" ];

                unpackPhase = "tar xf $src";

                installPhase = ''
                  mkdir -p $out${dataDirectorySuffix}
                  cp -R ./* $out${dataDirectorySuffix}
                '';
              };

            dataDirectory = dataPkg + dataDirectorySuffix;

            launcherScript = writeScriptBin launcherName ''
              #!${mksh}/bin/mksh
              cd ${dataDirectory}
              ${mfgtools}/bin/uuu ${name}.lst
            '';

          in
          launcherScript;

        releasesNarHashes = {
          purism-librem5 = {
            version = "0.8";
            narHash = "sha256-tEtl16tyu/GbAWceDXZTP4R+ajmAksIzwmwlWYZkTYc=";
          };
        };

        releases = mapAttrs mkRelease releasesNarHashes;

      in
      releases;
  };
}
