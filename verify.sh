#!/usr/bin/env bash
# =============================================================================
# verify.sh — Script de verificação/diagnóstico
# Execute após completar o bootstrap para verificar se tudo está OK
# =============================================================================
set -euo pipefail

# ── Colors ────────────────────────────────────────────────────────────────────
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
BLUE='\033[0;34m'; BOLD='\033[1m'; NC='\033[0m'

ok()   { echo -e "${GREEN}✓${NC} $*"; }
fail() { echo -e "${RED}✗${NC} $*"; }
warn() { echo -e "${YELLOW}!${NC} $*"; }
info() { echo -e "${BLUE}→${NC} $*"; }

header() {
  echo ""
  echo -e "${BOLD}${BLUE}═══════════════════════════════════════${NC}"
  echo -e "${BOLD}${BLUE}  $*${NC}"
  echo -e "${BOLD}${BLUE}═══════════════════════════════════════${NC}"
  echo ""
}

# ── Verificações ──────────────────────────────────────────────────────────────

header "Sistema"
echo "OS: $(lsb_release -ds 2>/dev/null || echo 'unknown')"
echo "Kernel: $(uname -r)"
echo "Shell: $SHELL"
echo ""

header "Pacotes Essenciais"
check_cmd() {
  if command -v "$1" &>/dev/null; then
    ok "$1: $(command -v "$1")"
  else
    fail "$1: não encontrado"
  fi
}

check_cmd git
check_cmd zsh
check_cmd nvim
check_cmd stow
check_cmd docker
check_cmd conda
check_cmd mise

header "Neovim"
if command -v nvim &>/dev/null; then
  nvim_version=$(nvim --version | head -n1)
  echo "$nvim_version"
  if [[ "$nvim_version" =~ "v0.12" ]] || [[ "$nvim_version" =~ "dev" ]]; then
    ok "Versão unstable detectada"
  else
    warn "Versão stable (alguns plugins podem não funcionar)"
  fi
else
  fail "Neovim não instalado"
fi
echo ""

header "ZSH + Oh My ZSH"
if [[ -d "$HOME/.oh-my-zsh" ]]; then
  ok "Oh My ZSH: instalado"
else
  fail "Oh My ZSH: não encontrado"
fi

if [[ -d "$HOME/.oh-my-zsh/custom/themes/powerlevel10k" ]]; then
  ok "Powerlevel10k: instalado"
else
  fail "Powerlevel10k: não encontrado"
fi

plugins=("zsh-autosuggestions" "zsh-syntax-highlighting" "zsh-completions")
for plugin in "${plugins[@]}"; do
  if [[ -d "$HOME/.oh-my-zsh/custom/plugins/$plugin" ]]; then
    ok "Plugin $plugin: instalado"
  else
    fail "Plugin $plugin: não encontrado"
  fi
done
echo ""

header "Conda"
if command -v conda &>/dev/null; then
  ok "Conda: $(conda --version)"
  
  info "Ambientes conda:"
  conda env list | grep -v "^#" | while read -r line; do
    if [[ -n "$line" ]]; then
      echo "  - $line"
    fi
  done
else
  fail "Conda não encontrado"
fi
echo ""

header "Docker"
if command -v docker &>/dev/null; then
  ok "Docker: $(docker --version)"
  
  if groups "$USER" | grep -q docker; then
    ok "Usuário no grupo 'docker'"
  else
    warn "Usuário NÃO está no grupo 'docker' (faça logout/login)"
  fi
else
  fail "Docker não instalado"
fi
echo ""

header "ROCm"
if command -v rocm-smi &>/dev/null; then
  ok "ROCm instalado"
  
  info "Versão do ROCm:"
  rocm-smi --showdriverversion 2>/dev/null || echo "  (não disponível)"
  
  info "GPUs detectadas:"
  rocm-smi 2>/dev/null | grep -A 5 "GPU" || echo "  Nenhuma GPU detectada"
  
  if groups "$USER" | grep -q "render\|video"; then
    ok "Usuário nos grupos render/video"
  else
    fail "Usuário NÃO está nos grupos render/video (reboot necessário)"
  fi
else
  fail "ROCm não instalado ou PATH não configurado"
fi
echo ""

header "PyTorch"
for env in rocm-env rocm-env-311; do
  env_path="$HOME/miniconda3/envs/$env"
  if [[ -d "$env_path" ]]; then
    info "Testando ambiente: $env"
    "$env_path/bin/python" -c "
import torch
print(f'  PyTorch: {torch.__version__}')
print(f'  ROCm disponível: {torch.cuda.is_available()}')
if torch.cuda.is_available():
    print(f'  GPU: {torch.cuda.get_device_name(0)}')
    print(f'  Dispositivos: {torch.cuda.device_count()}')
" 2>/dev/null || warn "Erro ao verificar PyTorch no ambiente $env"
    echo ""
  fi
done

header "Mise"
if command -v mise &>/dev/null; then
  ok "Mise: $(mise --version 2>/dev/null || echo 'instalado')"
  
  info "Ferramentas instaladas:"
  mise list 2>/dev/null || echo "  (nenhuma)"
else
  fail "Mise não encontrado"
fi
echo ""

header "Git"
if command -v git &>/dev/null; then
  ok "Git: $(git --version)"
  
  git_name=$(git config --global user.name 2>/dev/null || echo "não configurado")
  git_email=$(git config --global user.email 2>/dev/null || echo "não configurado")
  
  echo "  Nome: $git_name"
  echo "  Email: $git_email"
  
  if [[ -f "$HOME/.ssh/id_ed25519" ]]; then
    ok "Chave SSH: existe"
    echo "  Chave pública:"
    cat "$HOME/.ssh/id_ed25519.pub" | sed 's/^/    /'
  else
    warn "Chave SSH: não encontrada"
  fi
else
  fail "Git não instalado"
fi
echo ""

header "Dotfiles (GNU Stow)"
dotfiles_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/dotfiles"
if [[ -d "$dotfiles_dir" ]]; then
  ok "Diretório dotfiles existe: $dotfiles_dir"
  
  # Verificar se symlinks estão corretos
  if [[ -L "$HOME/.zshrc" ]]; then
    ok "~/.zshrc é um symlink"
  else
    warn "~/.zshrc NÃO é um symlink (dotfiles não instalados?)"
  fi
  
  if [[ -L "$HOME/.config/nvim" ]] || [[ -d "$HOME/.config/nvim" ]]; then
    ok "~/.config/nvim existe"
  else
    warn "~/.config/nvim não encontrado"
  fi
else
  fail "Diretório dotfiles não encontrado: $dotfiles_dir"
fi
echo ""

header "Resumo"
echo ""
echo "Se todos os itens acima estão com ✓, seu ambiente está configurado!"
echo ""
info "Próximos passos manuais:"
echo "  1. Terminal → Preferências → Fonte: MesloLGS NF Regular"
echo "  2. GitHub SSH: adicione ~/.ssh/id_ed25519.pub"
echo "  3. Powerlevel10k: p10k configure (se quiser reconfigurar)"
echo "  4. GNOME Tweaks: temas e ícones"
echo ""
