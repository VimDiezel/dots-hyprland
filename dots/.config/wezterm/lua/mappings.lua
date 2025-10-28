local wez = require "wezterm"
local act = wez.action
local mux = wez.mux
local callback = wez.action_callback

local mod = {
  c = "CTRL",
  s = "SHIFT",
  a = "ALT",
  l = "LEADER",
}

local keybind = function(mods, key, action)
  return { mods = table.concat(mods, "|"), key = key, action = action }
end

local M = {}

-- Smart split function for panes
M.smart_split = wez.action_callback(function(window, pane)
  local dim = pane:get_dimensions()
  if dim.pixel_height > dim.pixel_width then
    window:perform_action(act.SplitVertical { domain = "CurrentPaneDomain" }, pane)
  else
    window:perform_action(act.SplitHorizontal { domain = "CurrentPaneDomain" }, pane)
  end
end)

-- Function to activate and zoom the pane with any given pane ID
wez.on("focus-id-pane-zoom", function(window, pane, pane_id)
  local tab = window:mux_window():active_tab()
  for _, p in ipairs(tab:panes()) do
    if p:pane_id() == pane_id then
      -- Cycle through panes until we reach the target pane
      for _ = 1, #tab:panes() do
        if window:mux_window():active_pane():pane_id() == pane_id then
          -- Once we've found and focused the target pane, zoom it to fullscreen
          window:perform_action(wez.action.TogglePaneZoomState, pane)
          return
        end
        window:perform_action(wez.action.ActivatePaneDirection "Next", pane)
      end
      return
    end
  end
end)

-- Function to activate the pane with specific pane ID
wez.on("focus-id-pane", function(window, pane, target_pane_id)
  local tab = window:mux_window():active_tab()
  for _, p in ipairs(tab:panes()) do
    if p:pane_id() == target_pane_id then
      -- Cycle through panes until we reach the target pane
      for _ = 1, #tab:panes() do
        if window:mux_window():active_pane():pane_id() == target_pane_id then
          return
        end
        window:perform_action(wez.action.ActivatePaneDirection "Next", pane)
      end
      return
    end
  end
end)

local leader = { key = "F3", timeout_milliseconds = 3000 }

local keys = function()
  local keys = {
    -- CTRL-A, CTRL-A sends CTRL-A
    keybind({ mod.l, mod.c }, "a", act.SendString "\x01"),

    -- pane and tabs
    keybind({ mod.l, mod.s }, "_", act.SplitVertical { domain = "CurrentPaneDomain" }),
    keybind({ mod.l, mod.s }, "|", act.SplitHorizontal { domain = "CurrentPaneDomain" }),
    -- keybind({ mod.l }, "z", act.TogglePaneZoomState),
    keybind({ mod.l }, "Enter", act.TogglePaneZoomState),
    keybind({ mod.a, mod.c }, "Enter", M.smart_split),
    -- keybind({ mod.l }, "c", act.SpawnTab "CurrentPaneDomain"),
    keybind({ mod.l }, "t", act.SpawnTab "CurrentPaneDomain"),
    keybind({ mod.l, mod.s }, "t", act.ShowTabNavigator),
    keybind({ mod.l, mod.s, mod.c }, "t", act.ActivateKeyTable { name = "move_tab", one_shot = false }),
    keybind({ mod.l }, "z", act.PaneSelect {}),
    keybind({ mod.l }, "'", act.PaneSelect {}),
    keybind({ mod.c }, "'", act.PaneSelect {}),
    keybind({ mod.l }, "s", act.ActivateTabRelative(-1)),
    keybind({ mod.l }, "f", act.ActivateTabRelative(1)),
    keybind({ mod.l }, "d", act.ActivateLastTab),
    keybind({ mod.l }, "h", act.ActivatePaneDirection "Left"),
    keybind({ mod.l }, "j", act.ActivatePaneDirection "Down"),
    keybind({ mod.l }, "k", act.ActivatePaneDirection "Up"),
    keybind({ mod.l }, "l", act.ActivatePaneDirection "Right"),
    keybind({ mod.l }, "c", act.CloseCurrentPane { confirm = true }),
    keybind({ mod.l, mod.s }, "H", act.AdjustPaneSize { "Left", 5 }),
    keybind({ mod.l, mod.s }, "J", act.AdjustPaneSize { "Down", 5 }),
    keybind({ mod.l, mod.s }, "K", act.AdjustPaneSize { "Up", 5 }),
    keybind({ mod.l, mod.s }, "L", act.AdjustPaneSize { "Right", 5 }),
    keybind({ mod.l }, "r", act.ActivateKeyTable { name = "resize_pane", one_shot = false }),
    keybind({ mod.l }, "-", act.ShowLauncher),
    keybind({ mod.l }, "q", act.CloseCurrentTab { confirm = true }),
    keybind({ mod.l }, "Space", act.QuickSelect),
    keybind({ mod.l }, "v", act.ActivateCopyMode),
    keybind({ mod.l, mod.c }, "/", act.Search "CurrentSelectionOrEmptyString"),
    keybind(
      { mod.l },
      ";",
      wez.action_callback(function(window, pane)
        wez.emit("focus-id-pane-zoom", window, pane, 0)
      end)
    ),

    keybind(
      { mod.l },
      "y",
      wez.action_callback(function(window, pane)
        -- Send commands to current pane
        pane:send_text " qq"
        wez.sleep_ms(100)
        pane:send_text "cs; vim\r"
      end)
    ),

    keybind(
      { mod.l },
      "m",
      wez.action_callback(function(window, pane)
        wez.emit("focus-id-pane", window, pane, 1)
      end)
    ),

    keybind(
      { mod.l },
      "n",
      wez.action_callback(function(window, pane)
        wez.emit("focus-id-pane-zoom", window, pane, 1)
      end)
    ),

    keybind(
      { mod.l },
      "/",
      wez.action_callback(function(window, pane)
        wez.emit("focus-id-pane", window, pane, 2)
      end)
    ),

    keybind(
      { mod.l },
      ".",
      wez.action_callback(function(window, pane)
        wez.emit("focus-id-pane-zoom", window, pane, 2)
      end)
    ),

    -- keybind(
    --   { mod.l },
    --   "c",
    --   act.SpawnCommandInNewTab {
    --     args = { "pwsh", "-NoLogo", "-Command", "$host.ui.RawUI.WindowTitle = 'Pomodoro'; pomodoro" },
    --   }
    -- ),

    keybind(
      { mod.l },
      "e",
      act.PromptInputLine {
        description = wez.format {
          { Attribute = { Intensity = "Bold" } },
          { Foreground = { AnsiColor = "Fuchsia" } },
          { Text = "Renaming Tab Title...:" },
        },
        action = callback(function(win, _, line)
          if line == "" then
            return
          end
          win:active_tab():set_title(line)
        end),
      }
    ),

    -- creates a new tab with a given name and cdf
    keybind(
      { mod.l, mod.c },
      "t",
      act.PromptInputLine {
        description = wez.format {
          { Attribute = { Intensity = "Bold" } },
          { Foreground = { AnsiColor = "Fuchsia" } },
          { Text = "New Tab Name: " },
        },
        action = wez.action_callback(function(window, pane, line)
          if line then
            window:perform_action(
              act.SpawnCommandInNewTab {
                cwd = wez.home_dir,
                args = { "zsh" },
              },
              pane
            )

            -- Set title immediately
            window:active_tab():set_title(line)

            -- Send fcd command after delay
            wez.time.call_after(0.1, function()
              local new_pane = window:active_pane()
              new_pane:send_text "fcd\n"
            end)
          end
        end),
      }
    ),

    -- creates a new tab with cdf
    -- keybind(
    --   { mod.l, mod.s, mod.c },
    --   "t",
    --   act.SpawnCommandInNewTab {
    --     args = { "pwsh", "-NoExit", "-c", "cdf" },
    --   }
    -- ),

    -- creates a new tab with a given name in home_dir
    keybind(
      { mod.l, mod.c },
      "n",
      act.PromptInputLine {
        description = wez.format {
          { Attribute = { Intensity = "Bold" } },
          { Foreground = { AnsiColor = "Fuchsia" } },
          { Text = "New Tab Name: " },
        },
        action = wez.action_callback(function(window, pane, line)
          if line then
            window:perform_action(
              act.SpawnCommandInNewTab {
                cwd = wez.home_dir,
                args = { "zsh" },
                set_environment_variables = {
                  TAB_NAME = line,
                },
              },
              pane
            )
            -- Wait a moment and set the tab title
            wez.sleep_ms(100)
            window:active_tab():set_title(line)
          end
        end),
      }
    ),

    -- workspaces
    keybind({ mod.l }, "w", act.ShowLauncherArgs { flags = "FUZZY|WORKSPACES" }),

    -- Create new workspace with a given name
    keybind(
      { mod.l, mod.s },
      "w",
      act.PromptInputLine {
        description = wez.format {
          { Attribute = { Intensity = "Bold" } },
          { Foreground = { AnsiColor = "Fuchsia" } },
          { Text = "Create new workspace (cwd): " },
        },
        action = wez.action_callback(function(window, pane, line)
          if line then
            window:perform_action(act.SwitchToWorkspace { name = line }, pane)
          end
        end),
      }
    ),

    -- Create new workspace with a given name and run cdf command
    keybind(
      { mod.l, mod.c },
      "w",
      act.PromptInputLine {
        description = wez.format {
          { Attribute = { Intensity = "Bold" } },
          { Foreground = { AnsiColor = "Fuchsia" } },
          { Text = "Create new workspace (Fzf Dir): " },
        },
        action = wez.action_callback(function(window, pane, line)
          if line then
            window:perform_action(
              act.SwitchToWorkspace {
                name = line,
                spawn = {
                  cwd = wez.home_dir,
                  args = { "zsh" },
                },
              },
              pane
            )

            wez.time.call_after(0.1, function()
              local new_pane = window:active_pane()
              new_pane:send_text "fcd\n"
            end)
          end
        end),
      }
    ),

    -- Create new workspace with a given name in the root dir
    keybind(
      { mod.l, mod.s, mod.c },
      "w",
      act.PromptInputLine {
        description = wez.format {
          { Attribute = { Intensity = "Bold" } },
          { Foreground = { AnsiColor = "Fuchsia" } },
          { Text = "Create new workspace (Root Dir): " },
        },
        action = wez.action_callback(function(window, pane, line)
          if line then
            window:perform_action(
              act.SwitchToWorkspace {
                name = line,
                spawn = {
                  cwd = wez.home_dir,
                },
              },
              pane
            )
          end
        end),
      }
    ),

    -- Rename workspace
    keybind(
      { mod.l, mod.c },
      "r",
      act.PromptInputLine {
        description = wez.format {
          { Attribute = { Intensity = "Bold" } },
          { Foreground = { AnsiColor = "Fuchsia" } },
          { Text = "Rename Workspace: " },
        },
        action = wez.action_callback(function(window, pane, line)
          if line then
            local workspace = mux.get_active_workspace()
            mux.rename_workspace(workspace, line)
            window:perform_action(act.EmitEvent "update-status", pane)
          end
        end),
      }
    ),

    -- copy and paste
    keybind({ mod.c, mod.s }, "c", act.CopyTo "Clipboard"),
    keybind({ mod.c, mod.s }, "v", act.PasteFrom "Clipboard"),

    -- restart the shell with keybind
    keybind(
      { mod.c, mod.s },
      "r",
      callback(function(win, pane)
        -- Send the command to clear the screen and restart PowerShell
        pane:send_text "rs\r"
      end)
    ),

    -- launch spotify_player as a small pane in the bottom
    keybind(
      { mod.l },
      "p",
      act.SplitPane {
        direction = "Down",
        command = { args = { "/home/vimdiesel/.cargo/bin/spotify_player" } },
        size = { Cells = 6 },
      }
    ),

    -- launch shell as a small pane in the bottom
    -- keybind(
    --   { mod.l },
    --   "d",
    --   act.SplitPane {
    --     direction = "Down",
    --     size = { Cells = 8 },
    --   }
    -- ),

    -- update all plugins
    keybind(
      { mod.l },
      "u",
      callback(function(win)
        wez.plugin.update_all()
        win:toast_notification("wezterm", "plugins updated!", nil, 4000)
      end)
    ),

    -- keybind(
    --   { mod.l },
    --   "b",
    --   act.PromptInputLine {
    --     description = wez.format {
    --       { Attribute = { Intensity = "Bold" } },
    --       { Foreground = { AnsiColor = "Teal" } },
    --       { Text = "Enter run command: " },
    --     },
    --     action = callback(function(window, pane, line)
    --       if line == "" then
    --         return
    --       end
    --
    --       window:perform_action(
    --         act.SplitPane {
    --           direction = "Down",
    --           command = { args = { line } },
    --           size = { Cells = 10 },
    --         },
    --         pane
    --       )
    --     end),
    --   }
    -- ),
  }

  -- tab navigation
  for i = 1, 9 do
    table.insert(keys, keybind({ mod.l }, tostring(i), act.ActivateTab(i - 1)))
  end
  return keys
end

M.key_tables = {
  resize_pane = {
    { key = "h", action = act.AdjustPaneSize { "Left", 1 } },
    { key = "j", action = act.AdjustPaneSize { "Down", 1 } },
    { key = "k", action = act.AdjustPaneSize { "Up", 1 } },
    { key = "l", action = act.AdjustPaneSize { "Right", 1 } },
    { key = "Escape", action = "PopKeyTable" },
    { key = "Enter", action = "PopKeyTable" },
  },
  move_tab = {
    { key = "h", action = act.MoveTabRelative(-1) },
    { key = "j", action = act.MoveTabRelative(-1) },
    { key = "k", action = act.MoveTabRelative(1) },
    { key = "l", action = act.MoveTabRelative(1) },
    { key = "Escape", action = "PopKeyTable" },
    { key = "Enter", action = "PopKeyTable" },
  },
}

M.apply_to_config = function(c)
  c.treat_left_ctrlalt_as_altgr = true
  c.leader = leader
  c.keys = keys()
  c.key_tables = M.key_tables
end

return M
