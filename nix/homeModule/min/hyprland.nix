{ pkdjz, ... }:
let
  terminal = "foot";
  keyboardLauncher = "wofi --show drun";
  lockScreen = "swaylock --color 000000";
  turnOffScreens = "hyrctl dispatch dpms off";
  turnOnScreens = "hyrctl dispatch dpms on";

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
{
  home.packages = with pkdjz; [ hyprland-relative-workspace ];

  # (Todo theme)
  xdg.configFile."hypr/hyprland.conf".text = with keys; ''
    exec-once=waybar

    monitor=,preferred,auto,1

    input {
      kb_layout = us
      kb_variant=
      accel_profile = flat
      repeat_rate=50
      repeat_delay=350
      follow_mouse = 1
      mouse_refocus = 0
      sensitivity = 0
      touchpad {
        natural_scroll = yes
        disable_while_typing = no
      }
    }

    device {
      name = at-translated-set-2-keyboard
      kb_layout = us
      kb_variant=colemak
      kb_options = ctrl:nocaps,altwin:swap_alt_win
    }

    device {
      name = that-canadian-minidox
      kb_layout = us
      kb_variant=
    }

    general {
      gaps_in = 3
      gaps_out = 3
      border_size = 3
      col.active_border = rgb(fa00fa) rgb(ff00ff) 45deg
      col.inactive_border = rgba(28282899)
      layout = master
    }

    decoration {
      rounding = 0
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
    bind = $SUPER, Print, exec, grimblast copy area
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

    # bind = $SUPER, H, exec, warpd --hint
    # bind = $SUPER, D, exec, warpd --normal
    # bind = $SUPER, G, exec, warpd --grid

    bind = $SUPER, 1, workspace, r-1
    bind = $SUPER, 2, workspace, r+1
    bind = $SUPER_SHIFT, 1, movetoworkspace, r-1
    bind = $SUPER_SHIFT, 2, movetoworkspace, r+1

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

  services = {
    swayidle = {
      enable = true;
      systemdTarget = "hyprland-session.target";
      timeouts = [
        { timeout = 300; command = turnOffScreens; resumeCommand = turnOnScreens; }
        { timeout = 900; command = lockScreen; }
      ];
      events = [
      ];
    };
  };
}
