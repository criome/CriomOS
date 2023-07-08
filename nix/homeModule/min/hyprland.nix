{ kor, pkgs, pkdjz, krimyn, config, profile, hyraizyn, ... }:
with builtins;
let
  inherit (kor) mkIf;
  inherit (krimyn.spinyrz) saizAtList iuzColemak izNiksDev izSemaDev;
  inherit (krimyn) saiz;
  inherit (profile) dark;
  inherit (pkgs) writeText;
  inherit (hyraizyn.astra.mycin) modyl;

  hasQuickSyncSupport = modyl == "ThinkPadE15Gen2Intel";

  waylandQtpass = pkgs.qtpass.override { pass = waylandPass; };
  waylandPass = pkgs.pass.override { x11Support = false; waylandSupport = true; };

  terminal = "foot";
  keyboardLauncher = "wofi --show drun";

  swayArgz = {
    inherit iuzColemak optionalString;
    waybarEksek = nixProfileExec "waybar";
    swaylockEksek = nixProfileExec "swaylock";
    browser = matcSaiz saiz "" termBrowser "${nixProfileExec "qutebrowser"}" "${nixProfileExec "qutebrowser"}";
    launcher = "${nixProfileExec "wofi"} --show drun";
    shellTerm = shellLaunch "export SHELL=${zshEksek}; exec ${terminal} ${zshEksek}";
  };

  fontDeriveicynz = [ pkgs.noto-fonts-cjk ]
    ++ (optionals saizAtList.med (with pkgs; [
    pkdjz.nerd-fonts.firaCode
    fira-code
  ]));

  modifier = "SUPER";

  colemakKeys = {
    left = "N";
    right = "I";
    up = "U";
    down = "E";
    fullscreen = "T";
    specialWorkspace = "-";
    float = "SPACE";
  };

  keys = colemakKeys;

in
mkIf saizAtList.min {
  home.packages = with pkdjz; [ hyprland-relative-workspace ];

  # (Todo theme)
  xdg.configFile."hypr/hyprland.conf".text = with keys; ''
    exec-once=waybar

    monitor=,preferred,auto,1

    input {
      kb_layout = us
      kb_variant=colemak
      kb_options = ctrl:nocaps,altwin:swap_alt_win
      accel_profile = flat
      follow_mouse = 1
      mouse_refocus = 0
      sensitivity = 0
      touchpad {
        natural_scroll = yes
        disable_while_typing = no
      }
    }

    general {
      gaps_in = 0
      gaps_out = -1
      border_size = 0
      col.active_border = rgba(665c54ee) rgba(a65c54ee) 45deg
      col.inactive_border = rgba(28282899)
      layout = master
    }

    decoration {
      rounding = 0
      blur = yes
      blur_size = 4
      blur_passes = 2
      blur_new_optimizations = yes
      drop_shadow = yes
      shadow_range = 4
      shadow_render_power = 3
      col.shadow = rgba(1a1a1aee)
      fullscreen_opacity = 0.9999999
      dim_strength = 0.25
    }

    animations {
      enabled = yes
      bezier = myBezier, 0.05, 0.9, 0.1, 1.05
      animation = windows, 1, 7, myBezier
      animation = windowsOut, 1, 7, default, popin 80%
      animation = border, 1, 10, default
      animation = borderangle, 1, 8, default
      animation = fade, 1, 7, default
      animation = workspaces, 1, 6, default, slidevert
      animation = specialWorkspace, 1, 6, default, fade
    }

    dwindle {
      preserve_split = yes
      special_scale_factor = 1
    }

    master {
      new_is_master = no
      new_on_top = no
      mfact = 0.65
      special_scale_factor = 1
    }

    gestures {
      workspace_swipe = yes
    }


    binds {
      allow_workspace_cycles = yes
    }

    $SUPER = ${modifier}
    $SUPER_SHIFT = ${modifier}_SHIFT
    $SUPER_ALT = ${modifier}_ALT

    bind = $SUPER_SHIFT, Return, exec, ${terminal}
    bind = $SUPER, O, exec, ${keyboardLauncher}
    bind = $SUPER, Q, killactive
    bind = $SUPER, P, exec, dunstify --icon=$(grimblast save screen) Screenshot Captured.
    bind = , Print, exec, grimblast copy area
    bind = $SUPER_ALT, delete, exit
    bind = $SUPER, ${float}, togglefloating
    bind = $SUPER, B, centerwindow
    bind = $SUPER, X, pin
    bind = $SUPER, ${fullscreen}, fullscreen
    bind = $SUPER, ${specialWorkspace}, togglespecialworkspace
    bind = $SUPER_SHIFT, ${specialWorkspace}, movetoworkspace, special
    bind = $SUPER_SHIFT, ${specialWorkspace}, focuscurrentorlast
    bind = $SUPER, F2, togglespecialworkspace

    bind = $SUPER, Return, layoutmsg, swapwithmaster master
    bind = $SUPER, ${down}, layoutmsg, cyclenext
    bind = $SUPER, ${up}, layoutmsg, cycleprev
    bind = $SUPER_SHIFT, ${down}, layoutmsg, swapnext
    bind = $SUPER_SHIFT, ${up}, layoutmsg, swapprev
    bind = $SUPER, C, splitratio, exact 0.80
    bind = $SUPER, C, layoutmsg, orientationtop
    bind = $SUPER_SHIFT, C, splitratio, exact 0.65
    bind = $SUPER_SHIFT, C, layoutmsg, orientationleft
    bind = $SUPER, ${left}, layoutmsg, addmaster
    bind = $SUPER, ${right}, layoutmsg, removemaster
    bind = $SUPER_SHIFT, ${left}, splitratio, -0.05
    bind = $SUPER_SHIFT, ${right}, splitratio, +0.05

    bind = $SUPER, 1, exec, hyprland-relative-workspace b
    bind = $SUPER, 2, exec, hyprland-relative-workspace f
    bind = $SUPER_SHIFT, 1, exec, hyprland-relative-workspace b --with-window
    bind = $SUPER_SHIFT, 2, exec, hyprland-relative-workspace f --with-window

    layerrule = blur,ironbar
    layerrule = blur,rofi
    layerrule = blur,notifications

    windowrulev2 = nomaxsize,class:^(winecfg\.exe)$
    windowrulev2 = nomaxsize,class:^(osu\.exe)$
    windowrulev2 = opaque,class:^(kitty)$
    windowrulev2 = noblur,class:^(kitty)$
    windowrulev2 = tile,class:^(.qemu-system-x86_64-wrapped)$

    # Scroll through existing workspaces with super + scroll
    bind = $SUPER, mouse_down, workspace, e+1
    bind = $SUPER, mouse_up, workspace, e-1

    # Move/resize windows with super + LMB/RMB and dragging
    bindm = $SUPER, mouse:272, movewindow
    bindm = $SUPER, mouse:273, resizewindow

    # Change volume with keys
    # TODO: Change notification once at 0/100%
    bindl=, XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle && notify-send -t 2000 "Muted" "$(wpctl get-volume @DEFAULT_AUDIO_SINK@)"
    bindl=, XF86AudioRaiseVolume, exec, wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+ && notify-send -t 2000 "Raised volume to" "$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | tail -c 3)%"
    bindl=, XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%- && notify-send -t 2000 "Lowered volume to" "$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | tail -c 3)%"

    misc {
      disable_hyprland_logo = yes
      animate_manual_resizes = yes
      animate_mouse_windowdragging = yes
      disable_autoreload = yes
    }
  '';
}
