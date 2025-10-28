local wez = require "wezterm"
local utils = require "lua.utils"
local appearance = require "lua.appearance"
local mappings = require "lua.mappings"
local workspaces = require "lua.workspaces"
local bar = wez.plugin.require "https://github.com/adriankarlen/bar.wezterm"

local platform = utils.platform()
local c = {}

if wez.config_builder then
  c = wez.config_builder()
end

-- wez.on("update-status", function(window, pane)
--   local process_path = pane:get_foreground_process_name()
--   if process_path then
--     local process = process_path:match "([^/\\]+)$" or process_path
--     process = process:gsub("%.exe$", "") -- remove .exe if present
--     local tab = window:active_tab()
--     if tab then
--       tab:set_title(process)
--     end
--   end
-- end)

-- General configurations

-- Base font
c.font = wez.font("Cascadia Code", { weight = "Medium" })

c.font_rules = {

  {

    italic = true,

    -- intensity = "Half",

    font = wez.font("Cascadia Code", { weight = "Medium", italic = true }),
  },
}

-- Font rules for different styles
-- c.font_rules = {
--   -- For bold text
--   {
--     intensity = "Bold",
--     font = wez.font "Terminess Nerd Font", -- instead of Bold
--   },
--   -- -- Optional: for half intensity (like dim text)
--   -- {
--   --   intensity = "Half",
--   --   font = wez.font("Monocraft", { weight = "Light" }),
--   -- },
--   -- Optional: for italic text
--   {
--     italic = true,
--     font = wez.font("Terminess Nerd Font", { weight = "Medium", italic = false }),
--   },
-- }
-- c.line_height = 1.3

c.font_size = 13
c.command_palette_font_size = 13
c.enable_wayland = true
-- c.term = "wezterm"
c.command_palette_rows = 15
c.default_prog = { "zsh" }
c.adjust_window_size_when_changing_font_size = false
c.audible_bell = "Disabled"
-- c.force_reverse_video_cursor = true
c.scrollback_lines = 3000
c.default_workspace = "Main"
-- c.status_update_interval = 2000
c.max_fps = 120
-- c.default_domain = "WSL:archlinux"
-- c.default_cwd = os.getenv("USERPROFILE")

-- workspaces
workspaces.setup()

-- keys
mappings.apply_to_config(c)

-- bar
bar.apply_to_config(c, {
  modules = {
    zoom = {
      enabled = true,
      icon = wez.nerdfonts.md_fullscreen,
      color = 4,
    },
    username = {
      enabled = true,
      icon = wez.nerdfonts.fa_user_astronaut,
    },
    hostname = {
      enabled = false,
    },
    spotify = {
      enabled = true,
    },
    clock = {
      enabled = true,
      icon = wez.nerdfonts.md_clock,
      color = 5,
    },
  },
})

-- appearance
appearance.apply_to_config(c)

return c
