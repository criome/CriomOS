{ kor, lib, krimyn, pkgs, pkdjz, uyrld, ... }:
let
  inherit (builtins) readFile toJSON;
  inherit (kor) optionalString optionals;
  inherit (pkdjz) kynvyrt;
  inherit (krimyn) githubId;
  inherit (krimyn.spinyrz) izNiksDev iuzColemak saizAtList;
  inherit (pkgs) mksh;

  tokenaizdWrangler = pkgs.writeScriptBin "wrangler" ''
    #!${mksh}/bin/mksh
    export CLOUDFLARE_API_TOKEN=''${CLOUDFLARE_API_TOKEN:-''$(${pkgs.gopass}/bin/gopass show -o cloudflare.com/token)}
    exec "${pkgs.nodePackages_latest.wrangler}/bin/wrangler" "$@"
  '';

  tokenizedHub = pkgs.writeScriptBin "hub" ''
    #!${mksh}/bin/mksh
    export GITHUB_TOKEN=''${GITHUB_TOKEN:-''$(${pkgs.gopass}/bin/gopass show -o github.com/token)}
    export GITHUB_USER=''${GITHUB_USER:-''$(${pkgs.gopass}/bin/gopass show github.com/token login)}
    exec "${pkgs.gitAndTools.hub}/bin/hub" "$@"
  '';

  tokenizedWrappedHub = pkgs.runCommand "hub" { } ''
    mkdir -p $out/bin
    ln -s ${pkgs.hub}/share $out/
    ln -s ${tokenizedHub}/bin/hub $out/bin/
  '';

  lispDevPackages = with pkgs.lispPackages; [
    pkgs.sbcl
    pkdjz.ql2nix.ql2nix
    quicklisp
  ];

  niksDevPackages = with pkgs; [
    qrencode
    jmtpfs
    # start('bash')
    nix-prefetch-git
    # start('pythonPackages')
    ranger
    # C/C++
    binutils
    openssh
    nginx
    sdcv # cli dictionary
    jq
    djvulibre
    # NodeJS
    tokenaizdWrangler
    #== go
    ghq
    elvish
    lf
    tokenizedWrappedHub
    #== rust
    watchexec
    zola
    git-series
    nixpkgs-fmt
    tree-sitter
    gitAndTools.gitui
    # Haskell
    nvfetcher
    # Python
    # pkdjz.mach-nix.package # broken
    uyrld.kibord.kpBootCli
    # Manuals
    unbound.man
  ] ++ (with nodePackages; [
    stylelint
    postcss
    node2nix
  ]);

in
kor.mkIf saizAtList.med {
  programs = {
    starship = {
      enable = true;
      settings = {
        cmd_duration = {
          show_notifications = true;
          min_time_to_notify = 10000; #TODO('requires build flag')
        };
        git_status = {
          disabled = true;
        };
      };
    };
  };

  home = {
    packages = with pkgs; [
      # start('bash')
      taskwarrior
      # start('pythonPackages')
      yt-dlp
      # ocrmypdf
      # C/C++
      imagemagick
      opusTools
      mediainfo
      #== go
      gopass
      git-bug
      lazygit
      #== rust
    ]
    ++ optionals izNiksDev (niksDevPackages ++ lispDevPackages);

    file = {
      # ".config/jesseduffield/lazygit/config.yml".text = { };

      "gh/config.yml".text = toJSON {
        gitProtocol = "ssh";
      };

      ".config/rustfmt/rustfmt.toml".source = kynvyrt {
        neim = "rustfmt.toml";
        format = "toml";
        valiu = {
          edition = "2021";
        };
      };

      ".config/luaformatter/config.yaml".source = kynvyrt {
        neim = "luaFormatterConfig.yaml";
        format = "yaml";
        valiu = {
          indent_width = 2;
          continuation_indent_width = 2;
          align_args = false;
          align_parameter = false;
          align_table_field = false;
          spaces_inside_table_braces = true;
        };
      };

      # start('pythonConfigs')
      ".config/youtube-dl/config".text = ''
        -f 'bestvideo[ext=webm]+bestaudio[ext=webm]/best[ext=webm]/best'
      '';

      ".config/ranger/rc.conf".text = '' ''
        + (optionalString iuzColemak readFile ./colemak.conf);
      # end('pythonConfigs')

    };
  };
}
