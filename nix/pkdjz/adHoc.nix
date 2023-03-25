hob:
let
  inherit (builtins) mapAttrs;

in
{
  base16-styles = {
    lamdy = { src, stdenv }:
      stdenv.mkDerivation {
        name = "base16-styles";
        inherit src;
        phases = [ "unpackPhase" "installPhase" ];
        installPhase = ''
          mkdir -p $out/lib
          cp -R ./{scss,css,sass} $out/lib
        '';
      };
  };

  buttons = {
    lamdy = { src, stdenv }:
      stdenv.mkDerivation {
        name = "buttons";
        inherit src;
        phases = [ "unpackPhase" "installPhase" ];
        installPhase = ''
          mkdir -p $out/lib
          cp -R ./{scss,css} $out/lib
        '';
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

  flake-registry = {
    lamdy = { src, copyPathToStore }:
      copyPathToStore (src + /flake-registry.json);
  };

  flowblade = {
    lamdy = { flowblade, fetchFromGitHub, src }:
      flowblade.overrideAttrs (oldAttrs:
        { inherit src; });
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

  ndi = {
    lamdy =
      { src, lib, stdenv, requireFile, avahi, obs-studio-plugins }:
      let
        version = "5.5.x";
        majorVersion = builtins.head (builtins.splitVersion version);
        installerName = "Install_NDI_SDK_v${majorVersion}_Linux";

      in
      stdenv.mkDerivation rec {
        pname = "ndi";
        inherit version src;

        buildInputs = [ avahi ];

        buildPhase = ''
          echo y | ./${installerName}.sh
        '';

        installPhase = ''
          mkdir $out
          cd "NDI SDK for Linux";
          mv bin/x86_64-linux-gnu $out/bin
          for i in $out/bin/*; do
            patchelf --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" "$i"
          done
          patchelf --set-rpath "${avahi}/lib:${stdenv.cc.libc}/lib" $out/bin/ndi-record
          mv lib/x86_64-linux-gnu $out/lib
          for i in $out/lib/*; do
            if [ -L "$i" ]; then continue; fi
            patchelf --set-rpath "${avahi}/lib:${stdenv.cc.libc}/lib" "$i"
          done
          mv include examples $out/
          mkdir -p $out/share/doc/${pname}-${version}
          mv licenses $out/share/doc/${pname}-${version}/licenses
          mv logos $out/share/doc/${pname}-${version}/logos
          mv documentation/* $out/share/doc/${pname}-${version}/
        '';

        # Stripping breaks ndi-record.
        dontStrip = true;

        passthru.updateScript = ./update.py;

        meta = with lib; {
          homepage = "https://ndi.tv/sdk/";
          description = "NDI Software Developer Kit";
          platforms = [ "x86_64-linux" ];
          hydraPlatforms = [ ];
        };
      };
  };

  netresolve = {
    lamdy =
      { src
      , stdenv
      , bash
      , automake
      , autoconf
      , pkg-config
      , libtool
      , c-ares
      , libasyncns
      }:
      stdenv.mkDerivation {
        pname = "netresolve";
        version = src.shortRev;
        inherit src;
        nativeBuildInputs = [ pkg-config autoconf automake libtool ];
        buildInputs = [ c-ares libasyncns ];
        postPatch = ''
          substituteInPlace autogen.sh --replace "/bin/bash" "${bash}/bin/bash"
        '';
        configureScript = "./autogen.sh";
      };
  };

  nixStaticUnstable = {
    modz = [ "pkgsStatic" ];
    src = hob.nix;
    lamdy = { src, nixUnstable }:
      nixUnstable.overrideAttrs (attrs: {
        inherit src;
        hardeningEnable = [ "pie" ];
        hardeningDisable = [ "pie" ];
      });
  };

  pijulSrc = {
    modz = [ "pkdjz" ];
    lamdy = { fetchPijul }: fetchPijul {
      name = "pijul-repo";
      url = "https://nest.pijul.com/pijul/pijul";
      sha256 = "J0hPEUXHHLwDRVC+90Vz9thTi/znLQ2trJ6ktUG5tKQ=";
    };
  };

  pnpm2nix = {
    modz = [ "pkgs" "pkgsSet" ];
    lamdy = { kor, src, pkgs }:
      let
        inherit (kor) genNamedAttrs;
        versions = [ 12 14 ];

        mkPnpm2nixVersion = versionInt:
          let version = toString versionInt; in
          {
            name = "v${version}";
            value = (import src) {
              inherit pkgs;
              nodejs = pkgs."nodejs-${version}_x";
              nodePackages = pkgs.nodePackages;
            };
          };

      in
      genNamedAttrs versions mkPnpm2nixVersion;
  };

  postcss-scss = {
    modz = [ "pkdjz" ];
    lamdy = { src, pnpm2nix }:
      let
        inherit (pnpm2nix.v12) mkPnpmPackage;

      in
      mkPnpmPackage {
        inherit src;
        shrinkwrapYML = src + /pnpm-lock.yaml;
      };
  };

  gardevoir = {
    lamdy = { src, stdenv }:
      stdenv.mkDerivation {
        name = "gardevoir";
        inherit src;
        phases = [ "unpackPhase" "installPhase" ];
        installPhase = ''
          mkdir -p $out/lib/scss
          cp -R ./src/* $out/lib/scss
        '';
      };
  };

  obs-ndi = {
    modz = [ "pkgsSet" "pkgs" "pkdjz" ];
    src = null;
    lamdy = { pkgs, lib, stdenv, fetchFromGitHub, obs-studio, cmake, qt6Packages, ndi }:

      stdenv.mkDerivation rec {
        pname = "obs-ndi";
        version = "4.10.0";

        nativeBuildInputs = [ cmake ];
        buildInputs = [ obs-studio qt6Packages.qtbase ndi ];

        src = fetchFromGitHub {
          owner = "Palakis";
          repo = "obs-ndi";
          rev = "dummy-tag-${version}";
          sha256 = "sha256-eQ/hQ2AnwyBNOotqlUZq07m4FXoeir2f7cTVq594obc=";
        };

        patches = [
          (pkgs.path + /pkgs/applications/video/obs-studio/plugins/obs-ndi/hardcode-ndi-path.patch)
        ];

        postPatch = ''
          # Add path (variable added in hardcode-ndi-path.patch)
          sed -i -e s,@NDI@,${ndi},g src/obs-ndi.cpp

          # Replace bundled NDI SDK with the upstream version
          # (This fixes soname issues)
          rm -rf lib/ndi
          ln -s ${ndi}/include lib/ndi
        '';

        postInstall = ''
          mkdir $out/lib $out/share
          mv $out/obs-plugins/64bit $out/lib/obs-plugins
          rm -rf $out/obs-plugins
          mv $out/data $out/share/obs
        '';

        dontWrapQtApps = true;

        meta = with lib; {
          description = "Network A/V plugin for OBS Studio";
          homepage = "https://github.com/Palakis/obs-ndi";
          platforms = platforms.linux;
          hydraPlatforms = ndi.meta.hydraPlatforms;
        };
      };
  };

  open-color = {
    lamdy = { src, stdenv }:
      let
      in
      stdenv.mkDerivation {
        name = "open-color";
        inherit src;
        phases = [ "unpackPhase" "installPhase" ];
        installPhase = ''
          mkdir -p $out/lib/scss
          cp -R ./open-color.scss $out/lib/scss
        '';
      };
  };

  skylendar = {
    src = null;
    lamdy = { stdenv, fetchurl }:
      let
        pname = "skylendar";
        version = "5.0nn";
      in
      stdenv.mkDerivation {
        inherit pname version;
        src = fetchurl {
          url = "mirror://sourceforge/skylendar/${pname}-${version}.tar.xz";
          sha256 = "sha256-j7iCCzHXwffHdhQcyzxPBvQK+RXaY3QSjXUtHu463fI=";
        };
      };
  };

  wireguardNetresolved = {
    modz = [ "pkgs" "pkdjz" ];
    src = null;
    lamdy = { wireguard-tools, makeWrapper, netresolve }:
      let
        netresolveLibPath = "${netresolve}/lib";
        netresolvePreloads = "libnetresolve-libc.so.0 libnetresolve-asyncns.so.0";
      in
      wireguard-tools.overrideAttrs (attrs: {
        postInstall = ''
          wrapProgram $out/bin/wg \
            --prefix LD_LIBRARY_PATH : "${netresolveLibPath}" \
            --prefix LD_PRELOAD : "${netresolvePreloads}"
        '';
      });
  };

}
