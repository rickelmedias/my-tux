#!/usr/bin/env bash
# Script 05 - AMD ROCm para WSL
# Usa amdgpu-install com --usecase=wsl,rocm --no-dkms (sem kernel driver)
# Pré-requisito: driver Adrenalin Edition 26.1.1+ instalado no Windows
# Ref: https://rocm.docs.amd.com/projects/radeon-ryzen/en/latest/docs/install/installrad/wsl/install-radeon.html
set -euo pipefail

ROCM_VERSION="7.2"
AMDGPU_DEB="amdgpu-install_7.2.70200-1_all.deb"
AMDGPU_URL="https://repo.radeon.com/amdgpu-install/${ROCM_VERSION}/ubuntu/noble/${AMDGPU_DEB}"

# ── Verificar se já está instalado ───────────────────────────────────────────
if command -v rocm-smi &>/dev/null; then
  echo "→ ROCm já instalado."
  rocm-smi 2>/dev/null || true
  exit 0
fi

# ── Verificar que estamos no WSL ──────────────────────────────────────────────
if ! grep -qi "microsoft" /proc/version 2>/dev/null; then
  echo "✗ Este script é para WSL. Use a branch 'operational-system' para bare metal."
  exit 1
fi

echo "→ Baixando amdgpu-install ${ROCM_VERSION}..."
wget -q --show-progress -O "/tmp/${AMDGPU_DEB}" "${AMDGPU_URL}"

echo "→ Instalando pacote amdgpu-install..."
sudo apt update -qq
sudo apt install -y "/tmp/${AMDGPU_DEB}"
rm -f "/tmp/${AMDGPU_DEB}"

echo "→ Instalando ROCm para WSL (sem DKMS)..."
sudo amdgpu-install -y --usecase=wsl,rocm --no-dkms

echo "→ Adicionando usuário aos grupos render e video..."
sudo usermod -a -G render,video "$LOGNAME"

echo ""
echo "✓ ROCm ${ROCM_VERSION} instalado para WSL!"
echo ""
echo "  ⚠️  Feche e reabra o WSL para aplicar os grupos (render, video)."
echo "     Após isso, verifique com: rocminfo"
