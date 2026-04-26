#!/usr/bin/env bash
# Script 00 - Neovim Unstable (v0.12+)
# Necessário para alguns plugins modernos do LazyVim/NvChad
set -euo pipefail

NVIM_VERSION="v0.12.0-dev"

# Se já está instalado e é a versão unstable, pular
if command -v nvim &>/dev/null; then
  current_version=$(nvim --version | head -n1)
  if [[ "$current_version" =~ "v0.12" ]] || [[ "$current_version" =~ "dev" ]]; then
    echo "→ Neovim unstable já instalado: $current_version"
    exit 0
  fi
fi

echo "→ Adicionando PPA do Neovim Unstable..."
sudo add-apt-repository -y ppa:neovim-ppa/unstable
sudo apt update

echo "→ Instalando Neovim Unstable..."
sudo apt install -y neovim

echo ""
echo "✓ Neovim instalado:"
nvim --version | head -n1
