#!/bin/bash
# Restore Steam Big Picture fullscreen after a game exits.
#
# Unlike gamescope, Sway has no "restore previous fullscreen": once a game
# window takes over fullscreen (the steam_app_ rule in the Sway config) and then
# closes, Steam Big Picture is left tiled under the bar and Steam does not
# re-request it. Track the Steam window Sway currently has fullscreen and put it
# back when a game window closes. Desktop-mode and dialog windows are never
# fullscreen, so they are never touched.

# shellcheck source=/dev/null
source /opt/gow/bash-lib/utils.sh

command -v swaymsg >/dev/null 2>&1 || exit 0
command -v jq >/dev/null 2>&1 || exit 0

gow_log "[Steam] fullscreen-restore watcher started"

# In case Big Picture is already fullscreen before we start watching.
armed=$(swaymsg -t get_tree 2>/dev/null | jq -r '
  [recurse(.nodes[]?, .floating_nodes[]?)
   | select(.window_properties.class == "steam" and .fullscreen_mode == 1) | .id][0] // ""')

swaymsg -t subscribe -m '["window"]' \
  | jq --unbuffered -r '[.change,
                         (.container.id | tostring),
                         (.container.window_properties.class // "-"),
                         (.container.fullscreen_mode | tostring)] | @tsv' \
  | while IFS=$'\t' read -r change id class fs; do
      # Remember the Steam UI window that currently holds fullscreen.
      if [ "$class" = "steam" ] && [ "$fs" = "1" ]; then
        armed="$id"
      fi
      # When a game window closes, put that window back to fullscreen.
      # Ryujinx is launched as a non-Steam shortcut so it keeps its own class
      # instead of steam_app_*, and without it listed here Big Picture stays
      # tiled after quitting the emulator.
      case "$change:$class" in
        close:steam_app_*|close:Ryujinx)
          if [ -n "$armed" ]; then
            swaymsg "[con_id=$armed] fullscreen enable" >/dev/null 2>&1 || true
          fi
          ;;
      esac
    done
