#!/bin/sh

PERCENTAGE="$(pmset -g batt | grep -Eo "\d+%" | cut -d% -f1)"
CHARGING="$(pmset -g batt | grep 'AC Power')"

if [ "$PERCENTAGE" = "" ]; then
  exit 0
fi

case "${PERCENTAGE}" in
  9[0-9]|100) ICON=""
  ;;
  [6-8][0-9]) ICON=""
  ;;
  [3-5][0-9]) ICON=""
  ;;
  [1-2][0-9]) ICON=""
  ;;
  *) ICON=""
esac

if [[ "$CHARGING" != "" ]]; then
  sketchybar --set "$NAME" icon="" label="${PERCENTAGE}%" \
                            icon.color=0xffffffff label.color=0xffffffff
elif [[ "$PERCENTAGE" -lt 25 ]]; then
  sketchybar --set "$NAME" icon="$ICON" label="${PERCENTAGE}%" \
                            icon.color=0xffff0000 label.color=0xffff0000
else
  sketchybar --set "$NAME" icon="$ICON" label="${PERCENTAGE}%" \
                            icon.color=0xffffffff label.color=0xffffffff
fi
