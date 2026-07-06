# Homebrew — cache shellenv output (only regenerate if brew binary changes)
if [[ -f "/opt/homebrew/bin/brew" ]]; then
  _brew_cache="${XDG_CACHE_HOME:-$HOME/.cache}/brew-shellenv.zsh"
  if [[ ! -f "$_brew_cache" ]] || [[ "/opt/homebrew/bin/brew" -nt "$_brew_cache" ]]; then
    /opt/homebrew/bin/brew shellenv > "$_brew_cache"
  fi
  source "$_brew_cache"
  unset _brew_cache
fi

# Set the directory we want to store zinit and plugins
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"

# Download Zinit, if it's not there yet
if [ ! -d "$ZINIT_HOME" ]; then
   mkdir -p "$(dirname $ZINIT_HOME)"
   git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

# Source/Load zinit
source "${ZINIT_HOME}/zinit.zsh"

# Add in zsh plugins (turbo-loaded — deferred until after prompt renders)
zinit ice wait lucid; zinit light zsh-users/zsh-syntax-highlighting
zinit ice wait lucid; zinit light zsh-users/zsh-completions
zinit ice wait lucid; zinit light zsh-users/zsh-autosuggestions
zinit ice wait lucid; zinit light Aloxaf/fzf-tab

# Load completions — only rebuild dump once per day
autoload -Uz compinit
if [[ -n ~/.zcompdump(#qN.mh+24) ]]; then
  compinit
else
  compinit -C
fi

zinit cdreplay -q

# Prompt
eval "$(starship init zsh)"

# History
HISTSIZE=5000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
HISTDUP=erase
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups

# Completion styling
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'

# Aliases
alias ls='lsd -a'
alias cat='bat'
alias suggest='gh copilot --prompt'
alias explain='gh copilot --prompt'
alias co='copilot'
alias ga='git add'
alias gc='git commit'
alias gco='git checkout'
alias gf='git fetch'
alias gp='git pull'
alias gP='git push'
alias gs='git status'
alias standup='git standup -s'
alias gr='git rebase'
alias gd='git diff'
alias gl='git log --all --graph --since="1 week ago" --pretty=format:"%C(magenta)%h %C(white) %an  %ar%C(auto)  %D%n%s%n"'

# fnm (fast Node version manager — replaces nvm)
eval "$(fnm env --use-on-cd --shell zsh)"

# Environment variables
export REQUESTS_CA_BUNDLE=/Users/matthew.james/cert.pem
export NODE_EXTRA_CA_CERTS=/Users/matthew.james/cert.pem

export DOTNET_ROOT=/usr/local/share/dotnet
export PATH=$PATH:$DOTNET_ROOT:$DOTNET_ROOT/tools
export EDITOR=nvim

export HOMEBREW_NO_ENV_HINTS=1

# Auto-upgrade Homebrew packages on first shell of each Monday
if [[ "$(date +%u)" -eq 1 ]]; then
  _brew_stamp="${XDG_CACHE_HOME:-$HOME/.cache}/brew-weekly-upgrade"
  _today="$(date +%Y-%m-%d)"
  if [[ ! -f "$_brew_stamp" ]] || [[ "$(cat "$_brew_stamp")" != "$_today" ]]; then
    echo "[brew] Running weekly upgrade..."
    if brew update && brew upgrade; then
      echo "[brew] Weekly upgrade completed successfully."
    else
      echo "[brew] Weekly upgrade failed (exit code $?)."
    fi
    echo "$_today" > "$_brew_stamp"
  fi
  unset _brew_stamp _today
fi

# pnpm
export PNPM_HOME="/Users/matthew.james/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

source /opt/homebrew/opt/zsh-vi-mode/share/zsh-vi-mode/zsh-vi-mode.plugin.zsh

export PATH="$HOME/.local/bin:$PATH"

# Shell integrations
eval "$(fzf --zsh)"
eval "$(zoxide init --cmd cd zsh)"
