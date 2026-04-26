#!/usr/bin/env bash
# Script 09 - Dotfiles via GNU Stow
# GNU Stow cria symlinks dos dotfiles no diretório correto ($HOME)
# automaticamente. É simples, sem dependências, e o padrão da industria.
# ─────────────────────────────────────────────────────────────────────────────
# Estrutura esperada:
#   dotfiles/
#   ├── zsh/          → ~/.zshrc, ~/.p10k.zsh
#   ├── nvim/         → ~/.config/nvim/
#   └── git/          → ~/.gitconfig (se houver)
# ─────────────────────────────────────────────────────────────────────────────
set -euo pipefail

BOOTSTRAP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DOTFILES_DIR="$BOOTSTRAP_DIR/dotfiles"

if [[ ! -d "$DOTFILES_DIR" ]]; then
  echo "✗ Diretório dotfiles não encontrado: $DOTFILES_DIR"
  exit 1
fi

if ! command -v stow &>/dev/null; then
  echo "→ Instalando stow..."
  sudo apt install -y stow
fi

echo "→ Instalando dotfiles via GNU Stow..."
cd "$DOTFILES_DIR"

# Para cada pacote de dotfiles, aplicar stow
for package in */; do
  package="${package%/}"
  if [[ -d "$package" ]]; then
    echo "  Stowing: $package"
    
    # Defesa contra o conflito do ZSH: faz backup se o arquivo for real e não um link
    if [[ "$package" == "zsh" && -f "$HOME/.zshrc" && ! -L "$HOME/.zshrc" ]]; then
      echo "  ⚠️ Arquivo .zshrc real detectado. Movendo para .zshrc.bak..."
      mv "$HOME/.zshrc" "$HOME/.zshrc.bak"
    fi

    # --dir e --target absolutos resolvem o BUG do Perl com links complexos (ex: Steam)
    stow --dir="$DOTFILES_DIR" --target="$HOME" --restow "$package" 2>/dev/null || {
      echo "  ✗ Erro ao stowing $package. Verifique conflitos manualmente."
    }
  fi
done

echo ""
echo "✓ Dotfiles instalados via stow."
echo "  Para remover links: cd $DOTFILES_DIR && stow -D <pacote>"
echo "  Para atualizar: cd $DOTFILES_DIR && stow --restow <pacote>"
