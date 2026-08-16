# Set the directory we want to store zinit and plugins
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"

if [[ -f "$HOME/cert.pem" ]]; then
  export REQUESTS_CA_BUNDLE="$HOME/cert.pem"
  export NODE_EXTRA_CA_CERTS="$HOME/cert.pem"
  export SSL_CERT_FILE="$HOME/cert.pem"   # Python/httpx/OpenSSL (jiratui)
  export CURL_CA_BUNDLE="$HOME/cert.pem"   # curl

  export DOTNET_ROOT=/usr/local/share/dotnet
  export EDITOR=nvim
  export HOMEBREW_NO_ENV_HINTS=1
  export XDG_CONFIG_HOME="$HOME/.config"
  export MANPAGER="sh -c 'col -bx | bat -l man -p'"

  # pnpm
  export PNPM_HOME="$HOME/Library/pnpm"
  case ":$PATH:" in
    *":$PNPM_HOME:"*) ;;
    *) export PATH="$PNPM_HOME:$PATH" ;;
  esac
  # pnpm end
fi
