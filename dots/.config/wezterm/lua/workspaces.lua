local wez = require "wezterm"

local M = {}

function M.setup()
  wez.on("gui-startup", function()
    local workspace_tabs = "Home(T)"
    local workspace_panes = "Home(P)"
    local workspace = os.getenv "WEZTERM_WORKSPACE"

    if workspace == "Home_T" then
      M.setup_tabs_workspace(workspace_tabs)
    elseif workspace == "Home_P" then
      M.setup_panes_workspace(workspace_panes)
    else
      print "No workspace specified or invalid workspace."
    end
  end)
end

function M.setup_tabs_workspace(workspace_name)
  local _, first_tab, window = wez.mux.spawn_window {
    workspace = workspace_name,
  }

  -- Set up Title for workspace with tabs
  wez.on("format-window-title", function()
    return "WezTerm(T)"
  end)

  -- Create the first tab and open vim in it and rename the tab title
  first_tab:send_text "vim\r"
  window:active_tab():set_title ""

  -- Create the second tab and open spotify-player in it and rename the tab title
  local _, second_tab, _ = window:spawn_tab {}
  second_tab:send_text "spotify_player\r"
  window:active_tab():set_title ""

  -- Create the third tab and rename the tab title
  local _, third_tab, _ = window:spawn_tab {}
  window:active_tab():set_title ""

  -- After doing all that focus (activate) the first tab
  first_tab:activate()
end

function M.setup_panes_workspace(workspace_name)
  local tab, pane, window = wez.mux.spawn_window {
    workspace = workspace_name,
  }

  -- Set up Title for workspace with panes
  wez.on("format-window-title", function()
    return "WezTerm(P)"
  end)

  -- Rename the tab title
  window:active_tab():set_title ""

  -- Open vim in the first pane
  local gui_window = window:gui_window()
  pane:send_text "vim\r"

  -- Split and set up Spotify on the right
  wez.time.call_after(0.1, function()
    gui_window:perform_action(
      wez.action.SplitPane {
        direction = "Right",
        command = { args = { "spotify_player" } },
        size = { Percent = 32 },
      },
      pane
    )

    -- Split and set up the default shell downwards
    gui_window:perform_action(
      wez.action.SplitPane {
        direction = "Down",
        size = { Cells = 12 },
        command = {
          args = {
            "bash",
            "-lc",
            "cd /home/vimdiesel && ZDOTDIR=/home/vimdiesel/.config/zsh exec zsh -i",
          },
        },
      },
      pane
    )

    -- Re-activate the left main pane
    gui_window:perform_action(wez.action.ActivatePaneDirection "Left", pane)
  end)
end

return M
