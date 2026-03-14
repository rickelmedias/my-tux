#!/usr/bin/env bash
# Script 02 - ZSH + Oh My ZSH + Powerlevel10k + Plugins
set -euo pipefail

ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

# ── ZSH como shell padrão ─────────────────────────────────────────────────────
if [[ "$SHELL" != "$(which zsh)" ]]; then
  echo "→ Definindo ZSH como shell padrão..."
  chsh -s "$(which zsh)"
  echo "  ⚠️  Faça Logout/Login para ativar o ZSH antes de continuar."
fi

# ── Oh My ZSH ─────────────────────────────────────────────────────────────────
if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
  echo "→ Instalando Oh My ZSH..."
  RUNZSH=no CHSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
else
  echo "→ Oh My ZSH já instalado, pulando..."
fi

# ── Plugins ────────────────────────────────────────────────────────────────────
declare -A PLUGINS=(
  ["zsh-autosuggestions"]="https://github.com/zsh-users/zsh-autosuggestions"
  ["zsh-syntax-highlighting"]="https://github.com/zsh-users/zsh-syntax-highlighting"
  ["zsh-completions"]="https://github.com/zsh-users/zsh-completions"
)

for plugin in "${!PLUGINS[@]}"; do
  dir="$ZSH_CUSTOM/plugins/$plugin"
  if [[ ! -d "$dir" ]]; then
    echo "→ Instalando plugin: $plugin"
    git clone --depth=1 "${PLUGINS[$plugin]}" "$dir"
  else
    echo "→ Plugin $plugin já instalado."
  fi
done

# ── Powerlevel10k ──────────────────────────────────────────────────────────────
P10K_DIR="$ZSH_CUSTOM/themes/powerlevel10k"
if [[ ! -d "$P10K_DIR" ]]; then
  echo "→ Instalando Powerlevel10k..."
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$P10K_DIR"
else
  echo "→ Powerlevel10k já instalado."
fi

# ── Fontes MesloLGS NF ────────────────────────────────────────────────────────
FONT_DIR="$HOME/.local/share/fonts"
mkdir -p "$FONT_DIR"

declare -A FONTS=(
  ["MesloLGS NF Regular.ttf"]="https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Regular.ttf"
  ["MesloLGS NF Bold.ttf"]="https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold.ttf"
  ["MesloLGS NF Italic.ttf"]="https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Italic.ttf"
  ["MesloLGS NF Bold Italic.ttf"]="https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold%20Italic.ttf"
)

fonts_installed=false
for font in "${!FONTS[@]}"; do
  if [[ ! -f "$FONT_DIR/$font" ]]; then
    echo "→ Baixando fonte: $font"
    wget -q --show-progress -O "$FONT_DIR/$font" "${FONTS[$font]}"
    fonts_installed=true
  fi
done

if $fonts_installed; then
  echo "→ Atualizando cache de fontes..."
  fc-cache -fv
fi

echo ""
echo "✓ ZSH + Oh My ZSH + Powerlevel10k configurados."
echo ""
echo "  ⚠️  Próximos passos manuais (WSL):"
echo "  1. No terminal Windows (ex: Windows Terminal), configure a fonte 'MesloLGS NF Regular'"
echo "     Settings → Perfil Ubuntu → Appearance → Font face"
echo "  2. Após o dotfiles ser instalado (etapa 09), rode: p10k configure"
