hl.config({
  input = {
    kb_layout = "us, ru",
    kb_options = "grp:alt_shift_toggle,caps:escape,compose:menu",
    follow_mouse = 1,
    mouse_refocus = false,
    touchpad = {
      natural_scroll = false,
    },
  },

  general = {
    gaps_in = 2,
    gaps_out = 2,
    border_size = 1,
    col = {
      active_border = { colors = { "rgb(784b84)", "rgb(311432)" }, angle = 45 },
      inactive_border = "rgba(595959aa)",
    },
    resize_on_border = false,
    allow_tearing = false,
    layout = "dwindle",
  },

  ecosystem = {
    no_update_news = true,
  },

  decoration = {
    rounding = 2,
    rounding_power = 2,
    active_opacity = 1.0,
    inactive_opacity = 1.0,
    shadow = {
      enabled = true,
      range = 4,
      render_power = 3,
      color = "rgba(1a1a1aee)",
    },
    blur = {
      enabled = true,
      size = 3,
      passes = 1,
      vibrancy = 0.1696,
    },
  },

  animations = {
    enabled = true,
  },

  master = {
    new_status = "master",
  },

  misc = {
    force_default_wallpaper = 0,
    disable_hyprland_logo = true,
    key_press_enables_dpms = true,
    mouse_move_enables_dpms = false,
  },

  cursor = {
    no_hardware_cursors = true,
  },
})
