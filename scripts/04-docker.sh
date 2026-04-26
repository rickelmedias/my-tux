#!/usr/bin/env bash
# Script 04 - Docker Engine
set -euo pipefail

if command -v docker &>/dev/null; then
  echo "→ Docker já instalado: $(docker --version)"
  # Verificar grupo
  if groups "$USER" | grep -q docker; then
    echo "→ Usuário já no grupo 'docker'."
  else
    sudo usermod -aG docker "$USER"
    echo "  ⚠️  Grupo 'docker' adicionado. Faça logout/login para aplicar."
  fi
  exit 0
fi

echo "→ Removendo versões antigas do Docker..."
for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do
  sudo apt-get remove -y "$pkg" 2>/dev/null || true
done

echo "→ Configurando repositório oficial do Docker..."
sudo apt-get update
sudo apt-get install -y ca-certificates curl gnupg

sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
  -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] \
  https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

echo "→ Instalando Docker Engine..."
sudo apt-get update
sudo apt-get install -y \
  docker-ce \
  docker-ce-cli \
  containerd.io \
  docker-buildx-plugin \
  docker-compose-plugin

echo "→ Adicionando usuário ao grupo 'docker'..."
sudo usermod -aG docker "$USER"

echo "✓ Docker instalado: $(docker --version)"
echo "  ⚠️  Faça logout/login para usar Docker sem sudo."
