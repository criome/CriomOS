mkWebpageArgs@{ src, lib, kynvyrt, stdenv, firn, reseter-css, open-color, writeText }:
webpageArgs@{ src, name ? "website", theme ? "simple" }:

let
  inherit (lib) optionalAttrs concatStrings;
  inherit (builtins) concatStringsSep readFile;
  inherit (stdenv) mkDerivation;

  firnConfig = {
    site = {
      url = "";
      title = "";
      description = "";
      ignored_directories = [ ];
      data_directory = "data";
      clean_attachments = false;
      sass = "scss";
    };

    file = {
      table_of_contents = "no";
      todo_keywords = [ "TODO" "DONE" ];
    };

    tags = {
      create_tag_pages = true;
      url = "tags/";
      org = false;
      firn = true;
    };
  };

  yamlConfig = kynvyrt {
    neim = "config";
    valiu = firnConfig;
    format = "yaml";
  };

  scssPackages = [ reseter-css open-color ];

  mkScssUseString = scssPackage: ''
    @use "${scssPackage}${scssPackage.passthru.scssLib}";
  '';

  useThemeString = ''
    @use "${mkWebpageArgs.src}/_sass/${theme}";
  '';

  scssUses = concatStringsSep "\n"
    ((map mkScssUseString scssPackages)
      ++ [ useThemeString ]);

  mainScssFile = writeText "main.scss" scssUses;

  firnEnv = mkDerivation {
    name = "firnEnv";
    version = src.shortRev;
    inherit src;

    inherit scssPackages;

    buildPhase = ''
      mkdir -p _firn/sass
      for package in $scssPackages; do
          ln -s $package/lib/scss/* _firn/sass/
      done
      ln -s ${mkWebpageArgs.src}/layouts _firn/
      ln -s ${mainScssFile} _firn/sass/main.scss
      ln -s ${yamlConfig} _firn/config.yaml
    '';

    installPhase = ''
      mkdir -p $out/lib/_firn
      cp -r _firn/* $out/lib/_firn
    '';
  };

in
{
  inherit firnEnv;

  output = mkDerivation {
    inherit name;

    version = src.shortRev;
    inherit src;

    nativeBuildInputs = [ firn ];

    buildPhase = ''
      mkdir -p _firn/_site
      cp -R ${firnEnv}/lib/_firn/* ./_firn/
      chmod u+w -R _firn
      firn build
    '';

    installPhase = ''
      mkdir $out
      cp -r _firn/_site/* $out
    '';
  };
}
