mkWebpageArgs@{ src, lib, kynvyrt, stdenv, firn, reseter-css, writeText }:
webpageArgs@{ src, theme ? "simple" }:

let
  inherit (lib) optionalAttrs concatStrings;
  inherit (builtins) concatStringsSep readFile;

  firnFiles = mkWebpageArgs.src;

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

  mkScssImportString = scssPackage: concatStrings
    [ "@import " "\"" scssPackage scssPackage.passthru.scssLib "\"" ";" ];

  scssImports = concatStringsSep "\n"
    (map mkScssImportString scssPackages);

  mkWebpageScss = readFile (firnFiles + /_sass/main.scss);

  finalMainScss = concatStringsSep "\n"
    [ scssImports mkWebpageScss ];

  finalMainScssFile = writeText "main.scss" finalMainScss;

in
stdenv.mkDerivation {
  name = "website";
  version = src.shortRev;
  inherit src;

  nativeBuildInputs = [ firn ];

  patchPhase = ''
    mkdir _firn
    cp -R ${firnFiles}/* _firn/
    chmod u+w -R _firn
    cp -f ${finalMainScssFile} _firn/_sass/main.scss
    ln -s ${yamlConfig} _firn/config.yaml
  '';

  buildPhase = ''
    firn build
  '';

  installPhase = ''
    mkdir $out
    cp -r _firn/_site/* $out
  '';
}
