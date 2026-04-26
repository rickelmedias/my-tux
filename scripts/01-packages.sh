#!/usr/bin/env bash
# Script 01 - Pacotes essenciais do sistema
set -euo pipefail

BOOTSTRAP_TARGET="${BOOTSTRAP_TARGET:-$(grep -qi "microsoft" /proc/version 2>/dev/null && echo wsl || echo operational-system)}"

echo "→ Atualizando sistema..."
sudo apt update
sudo apt upgrade -y

echo "→ Instalando pacotes essenciais..."
packages=(
  build-essential \
  cmake \
  curl \
  wget \
  git \
  unzip \
  zip \
  libgl1 \
  zsh \
  neovim \
  stow \
  git-delta \
  ripgrep \
  fd-find \
  bat \
  htop \
  jq \
  tree \
  openssh-client \
  ca-certificates \
  gnupg \
  lsb-release \
  software-properties-common \
  uuid-runtime
)

if [[ "$BOOTSTRAP_TARGET" != "wsl" ]]; then
  packages+=(
    gnome-tweaks
    gnome-shell-extension-manager
    xclip
    dconf-cli
  )
fi

sudo apt install -y "${packages[@]}"

# bat é instalado como batcat no Ubuntu — criar alias
if command -v batcat &>/dev/null && ! command -v bat &>/dev/null; then
  mkdir -p ~/.local/bin
  ln -sf /usr/bin/batcat ~/.local/bin/bat
  echo "→ Alias bat → batcat criado em ~/.local/bin/bat"
fi

echo "✓ Pacotes do sistema instalados."
