# Check if we're running Homebrew
if [[ -f "/opt/homebrew/bin/brew" ]]; then
  # Homebrew — cache shellenv output (only regenerate if brew binary changes)
  _brew_cache="${XDG_CACHE_HOME:-$HOME/.cache}/brew-shellenv.zsh"
  if [[ ! -f "$_brew_cache" ]] || [[ "/opt/homebrew/bin/brew" -nt "$_brew_cache" ]]; then
    /opt/homebrew/bin/brew shellenv > "$_brew_cache"
  fi
  source "$_brew_cache"
  unset _brew_cache

  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# Added by Toolbox App
export PATH="$PATH:$HOME/Library/Application Support/JetBrains/Toolbox/scripts"
