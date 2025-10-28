#!/bin/bash

# Hyprland Window Management Script

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

    # If the target window is already focused, do nothing
    if [ "$target_address" = "$active_address" ]; then
      return 0
    fi

    # Focus the existing window
    hyprctl dispatch focuswindow "address:$target_address"
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

    # If the target window is already focused, do nothing
    if [ "$target_address" = "$active_address" ]; then
      return 0
    fi

    # Focus the existing window
    hyprctl dispatch focuswindow "address:$target_address"
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
    echo "For example: sudo pacman -S jq (Arch) or sudo apt install jq (Ubuntu)"
    exit 1
  fi
}

# Application handlers (equivalent to your AutoHotkey hotkeys)
launch_wezterm() {
  # Match WezTerm with specific title (exact match)
  handle_app "WezTerm(P):WezTerm(P)" "export WEZTERM_WORKSPACE=Home_P && wezterm start --class 'WezTerm(P)' --always-new-process"
}

launch_discord() {
  # Match Discord by class only
  handle_app "vesktop" "vesktop"
}

launch_browser() {
  # Match Zen browser by class
  handle_app "zen" "zen-browser"
}

launch_file_manager() {
  # Match file manager by class
  handle_app "org.kde.dolphin" "dolphin"
}

launch_whatsapp() {
  # Match WhatsApp with specific title (partial match)
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
    launch_wezterm
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
    echo "Usage: $0 {wezterm|discord|browser|files|whatsapp|spotify|info}"
    echo "Short forms: {w|d|b|e|g|s|i}"
    echo ""
    echo "This script focuses existing windows or launches applications if not found."
    echo "Use 'info' to see class and title information of current windows."
    echo "Designed to work with Hyprland on Wayland."
    echo ""
    echo "Criteria format examples:"
    echo "  handle_app \"class_name\" \"command\"           # Match by class only"
    echo "  handle_app \"class_name:exact_title\" \"command\" # Match class + exact title"
    echo "  handle_app \":title\" \"command\"               # Match by title only"
    echo "  handle_app_partial \"class:partial\" \"command\" # Match class + partial title"
    exit 1
    ;;
  esac
}

# Run main function with all arguments
main "$@"
