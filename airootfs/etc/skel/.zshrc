# HyperArch — zsh
export EDITOR=nvim
export BROWSER=brave
export PATH="$HOME/.local/bin:$PATH"

# ccache (MX-01): compilaciones repetidas casi instantáneas
export PATH="/usr/lib/ccache/bin:$PATH"
export CCACHE_DIR="$HOME/.cache/ccache"
export CCACHE_MAXSIZE="50G"

# Aprovechar los 24 hilos del 7900X3D (PR-13)
export MAKEFLAGS="-j$(nproc)"
export CARGO_BUILD_JOBS="$(nproc)"

# Historial
HISTFILE=~/.zsh_history
HISTSIZE=50000
SAVEHIST=50000
setopt SHARE_HISTORY HIST_IGNORE_ALL_DUPS HIST_REDUCE_BLANKS
setopt AUTO_CD EXTENDED_GLOB

# Plugins
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh 2>/dev/null
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh 2>/dev/null

# Herramientas modernas
alias ls="eza --icons --group-directories-first"
alias ll="eza -l --icons --git --group-directories-first"
alias la="eza -la --icons --git --group-directories-first"
alias tree="eza --tree --icons"
alias cat="bat --paging=never"
alias grep="rg"
alias find="fd"
alias top="btop"
alias vim="nvim"

# HyperArch
alias hy="hyper-hub"
alias hprod="hyper-production-mode"
alias hfocus="hyper-focus-mode"
alias hprofile="hyper-profile"
alias hai="journalctl -fu hyper-ai"
alias hlog="tail -f /var/log/hyper-ai.log"

# Docker
alias d="docker"
alias dc="docker compose"
alias lzd="lazydocker"
alias lg="lazygit"
alias mongo-up="docker compose -f ~/.config/hyperarch/mongodb.yml up -d"
alias mongo-down="docker compose -f ~/.config/hyperarch/mongodb.yml down"

# Snapshots
alias snap-list="sudo snapper -c root list"
alias snap-create="sudo snapper -c root create -d"

eval "$(zoxide init zsh)"
eval "$(starship init zsh)"
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# fastfetch solo en sesión interactiva de terminal nueva
[[ -o interactive ]] && command -v fastfetch >/dev/null && fastfetch

# Mantenimiento
alias hup="hyper-update"
alias hbackup="hyper-backup run"
alias hwall="hyper-wallpaper"
