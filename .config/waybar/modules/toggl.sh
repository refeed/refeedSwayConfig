#!/bin/sh

# Toggl Track waybar module.
# Reads the running timer from the Toggl browser tab title via swaymsg, e.g.
#   "08:39 min - Infra2Code Dev Sync - StackGuardian • Toggl Track — Original profile — Mozilla Firefox"
# and formats it to:
#   "08:39 min - Infra2Code Dev Sync"

icon=""

# Grab the first window/tab title containing the Toggl Track marker.
title=$(swaymsg -t get_tree | jq -r '
  [.. | objects | select(.name != null) | .name
   | select(test(" • Toggl Track"))][0] // empty')

if [ -z "$title" ]; then
  # No running timer visible.
  echo '{"text":"", "class":"idle"}'
  exit 0
fi

# Keep everything before " • Toggl Track" -> "08:39 min - Infra2Code Dev Sync - StackGuardian"
entry=${title%% • Toggl Track*}

# Drop the trailing " - <workspace>" segment, but only if there are >=2 separators
# so a "time - description" title (no workspace) is left intact.
case "$entry" in
  *" - "*" - "*) text=${entry% - *} ;;
  *)            text="$entry" ;;
esac

# Normalize the leading time token:
#   - drop the seconds:    "08:39 min" -> "08 min";  "1:23:45" -> "1:23"
#   - drop a leading zero:  "08 min" -> "8 min";  "01:03" -> "1:03";  "05 sec" -> "5 sec"
time=${text%% *}        # first token, e.g. "08:39", "1:23:45" or "05"
rest=${text#"$time"}    # remainder, e.g. " min - Infra2Code Dev Sync"
case "$time" in
  *:*) time=${time%:*} ;;     # MM:SS -> MM,  H:MM:SS -> H:MM
esac
case "$time" in
  0[0-9]*) time=${time#0} ;;  # strip a single leading zero
esac
# If the timer is still in seconds (e.g. "5 sec"), show "0 min" instead.
case "$rest" in
  " sec"*) time=0; rest=" min${rest#" sec"}" ;;
esac
text="$time$rest"

# Limit the displayed text to 45 characters (append an ellipsis when truncated).
text=$(printf '%s' "$text" | awk '{ if (length($0) > 45) print substr($0, 1, 44) "…"; else print $0 }')

# Emit JSON via jq so the text is escaped correctly.
jq -cn --arg text "$icon  $text" --arg full "$entry" \
  '{text: $text, tooltip: $full, class: "running"}'
