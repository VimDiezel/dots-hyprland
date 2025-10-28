local wez = require "wezterm"

-- local dimmer = { brightness = 0.1 }

local M = {}

M.apply_to_config = function(c)
  c.color_scheme = "rose-pine"
  local scheme = wez.color.get_builtin_schemes()["rose-pine"]

  c.colors = {
    split = scheme.ansi[2],
    cursor_bg = scheme.ansi[6],
    cursor_border = scheme.ansi[6],
    compose_cursor = scheme.ansi[2],
    selection_bg = "#403d52",
    -- scrollbar_thumb = scheme.ansi[7],
    tab_bar = {
      background = "transparent",
      active_tab = {
        bg_color = "transparent",
        fg_color = scheme.ansi[4],
      },
      inactive_tab = {
        bg_color = "transparent",
        fg_color = scheme.ansi[6],
      },
    },
  }

  -- c.background = {
  --   -- This is the deepest/back-most layer. It will be rendered first
  --   {
  --     source = {
  --       File = "C:/Users/VimDiesel/Downloads/Alien_Ship_bg_vert_images/Backgrounds/spaceship_bg_1.png",
  --     },
  --     -- The texture tiles vertically but not horizontally.
  --     -- When we repeat it, mirror it so that it appears "more seamless".
  --     -- An alternative to this is to set `width = "100%"` and have
  --     -- it stretch across the display
  --     repeat_x = "Mirror",
  --     hsb = dimmer,
  --     -- When the viewport scrolls, move this layer 10% of the number of
  --     -- pixels moved by the main viewport. This makes it appear to be
  --     -- further behind the text.
  --     attachment = { Parallax = 0.1 },
  --   },
  --   -- Subsequent layers are rendered over the top of each other
  --   {
  --     source = {
  --       File = "C:/Users/VimDiesel/Downloads/Alien_Ship_bg_vert_images/Overlays/overlay_1_spines.png",
  --     },
  --     width = "100%",
  --     repeat_x = "NoRepeat",
  --
  --     -- position the spins starting at the bottom, and repeating every
  --     -- two screens.
  --     vertical_align = "Bottom",
  --     repeat_y_size = "200%",
  --     hsb = dimmer,
  --
  --     -- The parallax factor is higher than the background layer, so this
  --     -- one will appear to be closer when we scroll
  --     attachment = { Parallax = 0.2 },
  --   },
  --   {
  --     source = {
  --       File = "C:/Users/VimDiesel/Downloads/Alien_Ship_bg_vert_images/Overlays/overlay_2_alienball.png",
  --     },
  --     width = "100%",
  --     repeat_x = "NoRepeat",
  --
  --     -- start at 10% of the screen and repeat every 2 screens
  --     vertical_offset = "10%",
  --     repeat_y_size = "200%",
  --     hsb = dimmer,
  --     attachment = { Parallax = 0.3 },
  --   },
  --   {
  --     source = {
  --       File = "C:/Users/VimDiesel/Downloads/Alien_Ship_bg_vert_images/Overlays/overlay_3_lobster.png",
  --     },
  --     width = "100%",
  --     repeat_x = "NoRepeat",
  --
  --     vertical_offset = "30%",
  --     repeat_y_size = "200%",
  --     hsb = dimmer,
  --     attachment = { Parallax = 0.4 },
  --   },
  --   {
  --     source = {
  --       File = "C:/Users/VimDiesel/Downloads/Alien_Ship_bg_vert_images/Overlays/overlay_4_spiderlegs.png",
  --     },
  --     width = "100%",
  --     repeat_x = "NoRepeat",
  --
  --     vertical_offset = "50%",
  --     repeat_y_size = "150%",
  --     hsb = dimmer,
  --     attachment = { Parallax = 0.5 },
  --   },
  -- }

  c.window_background_opacity = 0.75
  -- c.win32_system_backdrop = "Acrylic"
  c.inactive_pane_hsb = { brightness = 0.6 }
  c.command_palette_bg_color = "#26233a"
  c.command_palette_fg_color = scheme.foreground
  c.window_padding = { left = "1cell", right = 0, top = "0.01cell", bottom = 0 }
  c.window_decorations = "NONE"
  -- c.enable_scroll_bar = true
  -- c.min_scroll_bar_height = '2cell'
  c.show_new_tab_button_in_tab_bar = false
end

return M
