# ─────────────────────────────────────────────────────────────────
# ~/.zshrc — Configuração ZSH
# Gerenciado pelo linux-bootstrap via GNU Stow
# ─────────────────────────────────────────────────────────────────

# ── Powerlevel10k instant prompt (deve ficar no topo) ─────────────
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# ── Oh My ZSH ─────────────────────────────────────────────────────
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"
POWERLEVEL9K_DISABLE_CONFIGURATION_WIZARD=true

plugins=(
  git
  sudo
  history
  zsh-autosuggestions
  zsh-syntax-highlighting
  zsh-completions
  docker
  docker-compose
)

source "$ZSH/oh-my-zsh.sh"

# ── PATH ──────────────────────────────────────────────────────────
export PATH="$HOME/.local/bin:$PATH"
export PATH="/opt/rocm/bin:$PATH"

# ── Editor ────────────────────────────────────────────────────────
export EDITOR="nvim"
export VISUAL="nvim"

# ── ROCm / AMD GPU ───────────────────────────────────────────────
export LD_LIBRARY_PATH="/opt/rocm/lib:${LD_LIBRARY_PATH:-}"
export HSA_ENABLE_SDMA=0           # Recomendado para RDNA3 consumer
export ROCR_VISIBLE_DEVICES=0
# RX 7800 XT = gfx1101, suportada nativamente pelo ROCm 7.2
# Descomente APENAS se PyTorch não detectar a GPU:
# export HSA_OVERRIDE_GFX_VERSION=11.0.1

# ── Mise (runtime manager) ────────────────────────────────────────
[[ -f "$HOME/.local/bin/mise" ]] && eval "$($HOME/.local/bin/mise activate zsh)"

# ── Conda (inicialização mínima, sem ativar base) ──────────────────
if [[ -f "$HOME/miniconda3/etc/profile.d/conda.sh" ]]; then
  source "$HOME/miniconda3/etc/profile.d/conda.sh"
fi

# ── Aliases ───────────────────────────────────────────────────────
alias vim="nvim"
alias v="nvim"
alias ll="ls -lah --color=auto"
alias la="ls -A --color=auto"
alias ..="cd .."
alias ...="cd ../.."

# bat (instalado como batcat no Ubuntu)
if command -v batcat &>/dev/null; then
  alias bat="batcat"
  alias cat="batcat --style=plain"
fi

# fd (instalado como fdfind no Ubuntu)
if command -v fdfind &>/dev/null; then
  alias fd="fdfind"
fi

# git
alias gs="git status"
alias gl="git log --oneline --graph --decorate --all"
alias gd="git diff"

# Docker
alias dc="docker compose"
alias dps="docker ps"

# ── Histórico ─────────────────────────────────────────────────────
HISTSIZE=50000
SAVEHIST=50000
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt SHARE_HISTORY

# ── Powerlevel10k config ──────────────────────────────────────────
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
