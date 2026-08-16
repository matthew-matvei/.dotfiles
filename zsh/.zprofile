# Check if we're running Homebrew
if [[ -f "/opt/homebrew/bin/brew" ]]; then
  # Homebrew — cache shellenv output (only regenerate if brew binary changes)
  _brew_cache="${XDG_CACHE_HOME:-$HOME/.cache}/brew-shellenv.zsh"
  if [[ ! -f "$_brew_cache" ]] || [[ "/opt/homebrew/bin/brew" -nt "$_brew_cache" ]]; then
    /opt/homebrew/bin/brew shellenv > "$_brew_cache"
  fi
  source "$_brew_cache"
  unset _brew_cache

  # Auto-upgrade Homebrew packages on first shell of each Monday
  if [[ "$(date +%u)" -eq 1 ]]; then
  _brew_cache_dir="${XDG_CACHE_HOME:-$HOME/.cache}"
  _brew_stamp="${_brew_cache_dir}/brew-weekly-upgrade"
  _today="$(date +%Y-%m-%d)"
  if [[ ! -f "$_brew_stamp" ]] || [[ "$(cat "$_brew_stamp")" != "$_today" ]]; then
    mkdir -p "$_brew_cache_dir"
    echo "$_today" > "$_brew_stamp"
    echo "[brew] Running weekly upgrade..."
    if brew update && brew upgrade --no-ask; then
      echo "[brew] Weekly upgrade completed successfully."
    else
      echo "[brew] Weekly upgrade failed (exit code $?)."
      rm -f "$_brew_stamp"
    fi
  fi
  unset _brew_cache_dir _brew_stamp _today
  fi
fi


