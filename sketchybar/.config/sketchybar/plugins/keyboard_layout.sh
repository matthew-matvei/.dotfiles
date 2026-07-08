#!/bin/sh

LAYOUT=$(defaults read ~/Library/Preferences/com.apple.HIToolbox.plist AppleCurrentKeyboardLayoutInputSourceID 2>/dev/null)

case "$LAYOUT" in
  *Colemak*)
    sketchybar --set "$NAME" drawing=off
    ;;
  *)
    sketchybar --set "$NAME" drawing=on icon="󰌌" label="AU"
    ;;
esac
