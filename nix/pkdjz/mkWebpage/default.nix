{ src, lib, kynvyrt, stdenv, firn }:

{ content
, theme ? "simple"
}:

let
  inherit (lib) optionalAttrs;
  firnFiles = src;

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

in
stdenv.mkDerivation {
  name = "website";
  version = content.shortRev;
  src = content;

  nativeBuildInputs = [ firn ];

  patchPhase = ''
    mkdir _firn
    ln -s ${firnFiles}/* _firn/
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
