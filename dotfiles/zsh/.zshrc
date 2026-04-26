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

# ── Ambiente ──────────────────────────────────────────────────────
if grep -qi "microsoft" /proc/version 2>/dev/null; then
  export MY_TUX_TARGET="wsl"
else
  export MY_TUX_TARGET="operational-system"
fi

# ── PATH ──────────────────────────────────────────────────────────
export PATH="$HOME/.local/bin:/opt/rocm/bin:$PATH"

# ── Editor ────────────────────────────────────────────────────────
export EDITOR="nvim"
export VISUAL="nvim"

# ── ROCm / AMD GPU ────────────────────────────────────────────────
export ROCM_PATH=/opt/rocm
export LD_LIBRARY_PATH="/opt/rocm/lib:${LD_LIBRARY_PATH:-}"
export ROCR_VISIBLE_DEVICES=0
export HSA_ENABLE_SDMA=0

if [[ "$MY_TUX_TARGET" == "wsl" ]]; then
  export LD_LIBRARY_PATH="/opt/rocm/lib:/usr/lib/wsl/lib:${LD_LIBRARY_PATH:-}"
  export HSA_OVERRIDE_GFX_VERSION=11.0.0
  export AMD_SERIALIZE_COPY=1
  export HSA_ENABLE_DXG_DETECTION=1
fi

# ── Mise (runtime manager) ────────────────────────────────────────
[[ -f "$HOME/.local/bin/mise" ]] && eval "$($HOME/.local/bin/mise activate zsh)"

# ── Conda ─────────────────────────────────────────────────────────
if [[ -f "$HOME/miniconda3/etc/profile.d/conda.sh" ]]; then
  source "$HOME/miniconda3/etc/profile.d/conda.sh"
  conda activate base
fi

# ── Aliases ───────────────────────────────────────────────────────
alias vim="nvim"
alias v="nvim"
alias ll="ls -lah --color=auto"
alias la="ls -A --color=auto"
alias ..="cd .."
alias ...="cd ../.."

# bat / fd aliases
command -v batcat &>/dev/null && alias bat="batcat" && alias cat="batcat --style=plain"
command -v fdfind &>/dev/null && alias fd="fdfind"

# Git & Docker aliases
alias gs="git status"
alias gl="git log --oneline --graph --decorate --all"
alias gd="git diff"
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

# ── Funções Úteis ─────────────────────────────────────────────────
ytb() {
  yt-dlp "$@" \
    -f "bestvideo+bestaudio/best" \
    --merge-output-format webm \
    --write-description \
    --write-subs \
    --write-auto-subs \
    --convert-subs srt \
    --sub-langs "en.*" \
    --no-embed-subs \
    --embed-metadata \
    --output "$HOME/Downloads/%(upload_date>%Y-%m-%d)s, %(uploader)s - %(title)s [%(id)s].%(ext)s"
}

# ── Cheat Sheet: Fix ROCm PyTorch no WSL ──────────────────────────
rocm-help() {
  if [[ "$MY_TUX_TARGET" != "wsl" ]]; then
    echo "Este guia rapido e focado em WSL."
    return 0
  fi
  echo -e "\e[1;35mROCM-PYTORCH-WSL(1)\e[0m             \e[1;32mManual do Usuário\e[0m             \e[1;35mROCM-PYTORCH-WSL(1)\e[0m"
  echo -e "\n\e[1;33mNOME\e[0m"
  echo -e "    rocm-fix - Conserta o link do PyTorch com a GPU no WSL após updates."
  
  echo -e "\n\e[1;33mDESCRIÇÃO\e[0m"
  echo -e "    O PyTorch (Conda/Pip) traz sua própria \e[36mlibhsa-runtime64.so\e[0m interna."
  echo -e "    No WSL, essa lib interna ignora o driver do Windows e a \e[32mlibrocdxg\e[0m."
  echo -e "    Este manual ensina a forçar o PyTorch a usar a lib do sistema (\e[32m/opt/rocm/lib\e[0m)."

  echo -e "\n\e[1;33mPASSO A PASSO (A CURA)\e[0m"
  echo -e "    \e[1;37m1. Ative seu ambiente:\e[0m"
  echo -e "       conda activate rocm-env"
  
  echo -e "\n    \e[1;37m2. Localize a lib intrusa:\e[0m"
  echo -e "       ldd \$(python -c \"import torch; print(torch._C.__file__)\") | grep libhsa"
  echo -e "       \e[3m(Se o caminho apontar para 'site-packages/torch/lib', ela está lá)\e[0m"

  echo -e "\n    \e[1;37m3. Execute o 'Sequestro' da Lib:\e[0m"
  echo -e "       cd \$(python -c \"import os, torch; print(os.path.dirname(torch.__file__) + '/lib')\")"
  echo -e "       mv libhsa-runtime64.so libhsa-runtime64.so.bak"

  echo -e "\n    \e[1;37m4. Valide a Mudança:\e[0m"
  echo -e "       python -c \"import torch; print('ROCm:', torch.cuda.is_available())\""

  echo -e "\n\e[1;33mVARIÁVEIS DE AMBIENTE CRÍTICAS (RDNA3)\e[0m"
  echo -e "    \e[36mHSA_OVERRIDE_GFX_VERSION=11.0.0\e[0m  (Engana o HIP para aceitar a 7800 XT)"
  echo -e "    \e[36mHSA_ENABLE_SDMA=0\e[0m                (Evita crashes de memória no WSL)"
  echo -e "    \e[36mAMD_SERIALIZE_COPY=1\e[0m             (Sincroniza memória Windows <-> Linux)"

  echo -e "\n\e[1;31mNOTAS\e[0m"
  echo -e "    Sempre que rodar 'conda update torch' ou 'pip install --upgrade', "
  echo -e "    o passo 3 precisará ser repetido."
  echo -e "\n\e[1;35m─────────────────────────────────────────────────────────────────────────────\e[0m"
}
