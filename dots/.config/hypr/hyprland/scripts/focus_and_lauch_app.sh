#!/bin/bash

# Hyprland Window Management Script (Updated for v0.55+ Lua Engine)

# Function to handle application focus/launch
handle_app() {
  local criteria="$1"
  local launch_command="$2"

  # Get list of all windows from Hyprland
  local windows=$(hyprctl clients -j)

  # Parse criteria (format: "class:title" or "class:" or ":title")
  local app_class=""
  local app_title=""

  if [[ "$criteria" == *":"* ]]; then
    app_class="${criteria%%:*}"
    app_title="${criteria#*:}"
  else
    app_class="$criteria"
  fi

  # Build jq filter based on criteria
  local jq_filter=""
  if [ -n "$app_class" ] && [ -n "$app_title" ]; then
    # Match both class and title (exact match for title)
    jq_filter=".[] | select(.class == \"$app_class\" and .title == \"$app_title\")"
  elif [ -n "$app_class" ]; then
    # Match only class
    jq_filter=".[] | select(.class == \"$app_class\")"
  elif [ -n "$app_title" ]; then
    # Match only title
    jq_filter=".[] | select(.title == \"$app_title\")"
  else
    echo "Error: No criteria specified"
    return 1
  fi

  # Find matching window
  local target_address=$(echo "$windows" | jq -r "$jq_filter | .address" | head -n1)

  if [ -n "$target_address" ] && [ "$target_address" != "null" ]; then
    # Get currently focused window
    local active_address=$(hyprctl activewindow -j | jq -r '.address')

    # Force both addresses to lowercase to prevent case-mismatch bugs
    if [ "${target_address,,}" = "${active_address,,}" ]; then
      return 0
    fi

    # FIX: New v0.55+ Lua table syntax for window focusing
    hyprctl dispatch "hl.dsp.focus({ window = \"address:$target_address\" })"
  else
    # No matching window found, launch the application
    if [ -n "$launch_command" ]; then
      eval "$launch_command &"
    fi
  fi
}

# Enhanced function for partial title matching
handle_app_partial() {
  local criteria="$1"
  local launch_command="$2"

  # Get list of all windows from Hyprland
  local windows=$(hyprctl clients -j)

  # Parse criteria (format: "class:title" or "class:" or ":title")
  local app_class=""
  local app_title=""

  if [[ "$criteria" == *":"* ]]; then
    app_class="${criteria%%:*}"
    app_title="${criteria#*:}"
  else
    app_class="$criteria"
  fi

  # Build jq filter based on criteria (with partial title matching)
  local jq_filter=""
  if [ -n "$app_class" ] && [ -n "$app_title" ]; then
    # Match class and partial title
    jq_filter=".[] | select(.class == \"$app_class\" and (.title | contains(\"$app_title\")))"
  elif [ -n "$app_class" ]; then
    # Match only class
    jq_filter=".[] | select(.class == \"$app_class\")"
  elif [ -n "$app_title" ]; then
    # Match partial title
    jq_filter=".[] | select(.title | contains(\"$app_title\"))"
  else
    echo "Error: No criteria specified"
    return 1
  fi

  # Find matching window
  local target_address=$(echo "$windows" | jq -r "$jq_filter | .address" | head -n1)

  if [ -n "$target_address" ] && [ "$target_address" != "null" ]; then
    # Get currently focused window
    local active_address=$(hyprctl activewindow -j | jq -r '.address')

    # Force both addresses to lowercase to prevent case-mismatch bugs
    if [ "${target_address,,}" = "${active_address,,}" ]; then
      return 0
    fi

    # FIX: New v0.55+ Lua table syntax for window focusing
    hyprctl dispatch "hl.dsp.focus({ window = \"address:$target_address\" })"
  else
    # No matching window found, launch the application
    if [ -n "$launch_command" ]; then
      eval "$launch_command &"
    fi
  fi
}

# Check if required dependencies are available
check_dependencies() {
  local missing_deps=()

  command -v hyprctl >/dev/null 2>&1 || missing_deps+=("hyprctl")
  command -v jq >/dev/null 2>&1 || missing_deps+=("jq")

  if [ ${#missing_deps[@]} -ne 0 ]; then
    echo "Error: Missing required dependencies: ${missing_deps[*]}"
    echo "Please install them using your package manager."
    exit 1
  fi
}

# Application handlers
launch_wezterm_T() {
  handle_app "WezTerm(T):WezTerm(T)" "export WEZTERM_WORKSPACE=Home_T && wezterm start --class 'WezTerm(T)' --always-new-process"
}

launch_wezterm_P() {
  handle_app "WezTerm(P):WezTerm(P)" "export WEZTERM_WORKSPACE=Home_P && wezterm start --class 'WezTerm(P)' --always-new-process"
}

launch_discord() {
  handle_app "equibop" "equibop"
}

launch_browser() {
  handle_app "zen" "zen-browser"
}

launch_file_manager() {
  handle_app "org.kde.dolphin" "dolphin"
}

launch_whatsapp() {
  handle_app_partial "whatsapp-for-linux:WhatsApp" "whatsapp-for-linux"
}

# Utility function to show current window information
show_window_info() {
  echo "Current active window:"
  hyprctl activewindow -j | jq -r '"Class: " + .class + "\nTitle: " + .title'
  echo ""
  echo "All windows:"
  hyprctl clients -j | jq -r '.[] | "Class: " + .class + " | Title: " + .title'
}

# Main execution
main() {
  check_dependencies

  case "$1" in
  "wezterm" | "w")
    launch_wezterm_T
    ;;
  "discord" | "d")
    launch_discord
    ;;
  "browser" | "b")
    launch_browser
    ;;
  "files" | "e")
    launch_file_manager
    ;;
  "whatsapp" | "g")
    launch_whatsapp
    ;;
  "info" | "i")
    show_window_info
    ;;
  *)
    echo "Usage: $0 {wezterm|discord|browser|files|whatsapp|info}"
    exit 1
    ;;
  esac
}

main "$@"
