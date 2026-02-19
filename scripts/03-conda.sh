#!/usr/bin/env bash
# Script 03 - Miniconda
set -euo pipefail

CONDA_DIR="$HOME/miniconda3"
INSTALLER="/tmp/miniconda.sh"

if [[ -d "$CONDA_DIR" ]]; then
  echo "→ Miniconda já instalado em $CONDA_DIR"
  exit 0
fi

echo "→ Baixando Miniconda3..."
wget -q --show-progress \
  "https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh" \
  -O "$INSTALLER"

echo "→ Instalando Miniconda3 em $CONDA_DIR..."
bash "$INSTALLER" -b -p "$CONDA_DIR"
rm -f "$INSTALLER"

echo "→ Inicializando conda para zsh..."
"$CONDA_DIR/bin/conda" init zsh

echo "→ Configurando conda (sem ativar base por padrão)..."
"$CONDA_DIR/bin/conda" config --set auto_activate_base false

echo "→ Aceitando Termos de Serviço (ToS) do Anaconda..."
"$CONDA_DIR/bin/conda" tos accept --override-channels --channel https://repo.anaconda.com/pkgs/main 2>/dev/null || true
"$CONDA_DIR/bin/conda" tos accept --override-channels --channel https://repo.anaconda.com/pkgs/r 2>/dev/null || true

echo "✓ Miniconda instalado. Reinicie o terminal ou rode: source ~/.zshrc"
