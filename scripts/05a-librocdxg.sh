#!/usr/bin/env bash
# Script 05a - librocdxg (WSL only)
# Compila e instala librocdxg para habilitar ROCm no WSL via dxgkrnl.
# Requer: ROCm instalado, Windows SDK instalado no Windows, cmake, gcc.
set -euo pipefail

WIN_SDK_VERSION="${WIN_SDK_VERSION:-}"
WIN_SDK_BASE="/mnt/c/Program Files (x86)/Windows Kits/10/Include"

if [[ -f /opt/rocm/lib/librocdxg.so ]]; then
  echo "→ librocdxg já instalado."
  exit 0
fi

if [[ -z "$WIN_SDK_VERSION" ]]; then
  echo "✗ WIN_SDK_VERSION não definida no .env"
  echo "  Verifique com: ls \"${WIN_SDK_BASE}/\""
  exit 1
fi

WIN_SDK_PATH="${WIN_SDK_BASE}/${WIN_SDK_VERSION}"
if [[ ! -d "$WIN_SDK_PATH/shared" ]]; then
  echo "✗ Windows SDK não encontrado em: ${WIN_SDK_PATH}/shared"
  echo "  Instale o Windows SDK e verifique WIN_SDK_VERSION no .env"
  exit 1
fi

echo "→ Windows SDK encontrado: ${WIN_SDK_VERSION}"

BUILD_DIR="/tmp/librocdxg-build"
rm -rf "$BUILD_DIR"
git clone --depth 1 https://github.com/ROCm/librocdxg.git "$BUILD_DIR"

mkdir -p "$BUILD_DIR/build"
cd "$BUILD_DIR/build"

echo "→ Compilando librocdxg..."
cmake .. -DWIN_SDK="${WIN_SDK_PATH}/shared"
make -j"$(nproc)"

echo "→ Instalando librocdxg..."
sudo make install

rm -rf "$BUILD_DIR"

echo "✓ librocdxg instalado em /opt/rocm/lib/librocdxg.so"
