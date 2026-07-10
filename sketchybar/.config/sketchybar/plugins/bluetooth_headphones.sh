#!/bin/sh

BLUETOOTH_INFO="$(system_profiler SPBluetoothDataType 2>/dev/null)"

HEADSET_CONNECTED="$(printf '%s\n' "$BLUETOOTH_INFO" | awk '
function trim(s) {
  sub(/^[[:space:]]+/, "", s)
  sub(/[[:space:]]+$/, "", s)
  return s
}
/^[[:space:]]*Connected:/ {
  in_connected = 1
  next
}
/^[[:space:]]*Not Connected:/ {
  exit
}
{
  if (!in_connected) next

  if ($0 ~ /^          [^ ].*:[[:space:]]*$/) {
    current_type = ""
    next
  }

  if ($0 ~ /Minor Type:/) {
    line = $0
    sub(/^.*Minor Type:[[:space:]]*/, "", line)
    current_type = trim(line)
    t = tolower(current_type)
    if (t ~ /headset/ || t ~ /headphone/ || t ~ /earbud/) {
      print "yes"
      exit
    }
  }
}
')"

if [ "$HEADSET_CONNECTED" != "yes" ]; then
  sketchybar --set "$NAME" drawing=off
  exit 0
fi

sketchybar --set "$NAME" drawing=on icon="󰋋" icon.drawing=on label.drawing=off
