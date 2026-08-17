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
zinit light jeffreytse/zsh-vi-mode

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
alias ls='lsd --long --git'
alias cat='bat'
alias suggest='gh copilot --prompt'
alias explain='gh copilot --prompt'
alias ga='git add'
alias gc='git commit'
alias gco='git checkout'
alias gf='git fetch'
alias gp='git pull'
alias gP='git push'
alias gs='git status'
alias gr='git rebase'
alias gd='git diff'
alias gl='git log --all --graph --since="1 week ago" --pretty=format:"%C(magenta)%h %C(white) %an  %ar%C(auto)  %D%n%s%n"'
alias gf='git fetch'
alias gash='gh dash'
alias x='exit'
alias gb='git branch'
alias gm='git merge'
alias gml='git merge-latest'
alias pr='gh pr create'
alias gwt='git worktree'
alias v='nvim'
alias oc='opencode'

# fnm (fast Node version manager — replaces nvm)
eval "$(fnm env --use-on-cd --shell zsh)"

export PATH=$PATH:$DOTNET_ROOT:$DOTNET_ROOT/tools
export PATH=$PATH:$HOME/.dotnet/tools
export PATH=$PATH:$HOME/.bin
export PATH="$HOME/.local/bin:$PATH"

# Shell integrations
eval "$(fzf --zsh)"
eval "$(zoxide init --cmd cd zsh)"

# Custom functions

# Defines a shortcut for 'yazi' whereby exiting with 'q' updates the 'pwd' to the last opened directory
function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	command yazi "$@" --cwd-file="$tmp"
	IFS= read -r -d '' cwd < "$tmp"
	[ "$cwd" != "$PWD" ] && [ -d "$cwd" ] && builtin cd -- "$cwd"
	command rm -f -- "$tmp"
}

set_unaliased_title() {
  print -Pn "\e]0;$3\a"
}

reset_title() {
  print -Pn "\e]0;%~\a"
}

# Safely append to Zsh's hook arrays to prevent terminal emulator from overwriting the title
autoload -Uz add-zsh-hook
add-zsh-hook preexec set_unaliased_title
add-zsh-hook precmd reset_title

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
