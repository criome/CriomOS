{ kor, pkgs, pkdjz, krimyn, config, profile, hyraizyn, ... }:
let
  inherit (builtins) readFile mapAttrs;
  inherit (kor) mkIf optionals optionalString matcSaiz;
  inherit (krimyn.spinyrz) saizAtList iuzColemak izNiksDev izSemaDev;
  inherit (krimyn) saiz;
  inherit (profile) dark;
  inherit (pkgs) writeText;
  inherit (hyraizyn.astra.mycin) modyl;

  shellLaunch = command: "${shell} -c '${command}'";
  homeDir = config.home.homeDirectory;
  nixProfileExec = name: "${homeDir}/.nix-profile/bin/${name}";

  shell = zshEksek;
  zshEksek = nixProfileExec "zsh";
  neovim = nixProfileExec "nvim";
  elementaryCode = nixProfileExec "io.elementary.code";
  termVis = shellLaunch "exec ${terminal} -e  ${nixProfileExec "vis"}";
  termNeovim = shellLaunch "exec ${terminal} -e ${neovim}";
  termBrowser = shellLaunch "exec ${terminal} -e ${nixProfileExec "w3m"}";
  terminal = nixProfileExec "foot";

  swayArgz = {
    inherit iuzColemak optionalString;
    waybarEksek = nixProfileExec "waybar";
    swaylockEksek = nixProfileExec "swaylock";
    browser = matcSaiz saiz "" termBrowser "${nixProfileExec "qutebrowser"}" "${nixProfileExec "qutebrowser"}";
    launcher = "${nixProfileExec "wofi"} --show drun";
    shellTerm = shellLaunch "export SHELL=${zshEksek}; exec ${terminal} ${zshEksek}";
  };

  swayConfigString = import ./swayConf.nix swayArgz;

in
mkIf saizAtList.min {
  wayland.windowManager.sway = {
    enable = true;
    wrapperFeatures = { base = true; gtk = true; };
    systemd.enable = true;
    extraSessionCommands = '' '';
    config = null;
    extraConfig = swayConfigString;
  };
}
