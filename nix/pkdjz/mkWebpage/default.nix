mkWebpageArgs@{ src, lib, kynvyrt, stdenv, firn, reseter-css, base16-styles, writeText }:
webpageArgs@{ src, name ? "website", theme ? "tomorrow" }:

let
  inherit (lib) optionalAttrs concatStrings concatMapStringsSep;
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

  scssPackages = [ reseter-css ];

  sassLibrariesPath = "_firn/sass";

  linkSassLibrary = package: ''
    ln -s ${package}/lib/scss ${sassLibrariesPath}/${package.name}
  '';

  linkSassLibrariesBash = concatMapStringsSep "\n" linkSassLibrary scssPackages;

  firnEnv = mkDerivation {
    name = "firnEnv";
    version = "alpha";
    inherit (mkWebpageArgs) src;

    buildPhase = ''
      mkdir -p ${sassLibrariesPath}
      ${linkSassLibrariesBash}
      ln -s ${base16-styles}/lib/scss/base16-${theme}.scss ${sassLibrariesPath}/_theme.scss
      ln -s ${mkWebpageArgs.src}/layouts _firn/
      ln -s ${mkWebpageArgs.src}/_sass/main.scss _firn/sass/main.scss
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

    version = src.shortRev or "unversioned";
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
