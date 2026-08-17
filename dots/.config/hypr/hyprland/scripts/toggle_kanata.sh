#!/bin/bash

if pgrep -f "kanata-tray-linux" >/dev/null; then
  pkill -f "kanata-tray-linux"
  echo "Kanata stopped."
else
  ~/apps/kanata-tray-linux &
  echo "Kanata started."
fi
