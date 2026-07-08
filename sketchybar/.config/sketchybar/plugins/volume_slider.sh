#!/bin/sh

# $PERCENTAGE is provided by sketchybar when the slider is dragged (0-100)
osascript -e "set volume output volume $PERCENTAGE"

case "$PERCENTAGE" in
  [6-9][0-9]|100) ICON="󰕾"
  ;;
  [3-5][0-9]) ICON="󰖀"
  ;;
  [1-9]|[1-2][0-9]) ICON="󰕿"
  ;;
  *) ICON="󰖁"
esac

sketchybar --set volume icon="$ICON"
