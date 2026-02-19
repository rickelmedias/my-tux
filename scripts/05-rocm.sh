#!/usr/bin/env bash
# Script 05 - AMD ROCm 7.2 (userspace only)
# GPU: RX 7800 XT (gfx1101, RDNA3)
# ─────────────────────────────────────────────────────────────────────────────
# NOTA: amdgpu-dkms da AMD não compila em kernels >= 6.13 (bug conhecido AMD).
# Kernels modernos (6.14, 6.17+) já têm o driver amdgpu embutido — basta
# instalar o userspace do ROCm e apontar para o módulo do kernel existente.
# Issues AMD: github.com/ROCm/ROCm/issues/4619, #5074, #5624
# ─────────────────────────────────────────────────────────────────────────────
set -euo pipefail

ROCM_VERSION="7.2"

# ── Verificar se ROCm já está instalado ───────────────────────────────────────
if command -v rocm-smi &>/dev/null; then
  echo "→ ROCm já instalado."
  rocm-smi --showdriverversion 2>/dev/null || true
  exit 0
fi

# ── Verificar driver amdgpu do kernel ─────────────────────────────────────────
echo "→ Verificando driver amdgpu no kernel..."
KERNEL=$(uname -r)
echo "  Kernel: $KERNEL"

if lsmod | grep -q "^amdgpu"; then
  echo "  ✓ amdgpu já carregado no kernel — não é necessário o DKMS da AMD."
else
  echo "  ⚠️  amdgpu não carregado. Tentando carregar..."
  sudo modprobe amdgpu || {
    echo "  ✗ Falha ao carregar amdgpu. Verifique se a GPU está conectada."
    exit 1
  }
fi

# ── Chave GPG da AMD ──────────────────────────────────────────────────────────
echo "→ Adicionando chave GPG da AMD..."
sudo mkdir -p /etc/apt/keyrings
wget -qO - https://repo.radeon.com/rocm/rocm.gpg.key \
  | gpg --dearmor \
  | sudo tee /etc/apt/keyrings/rocm.gpg > /dev/null

# ── Repositório ROCm 7.2 (só userspace, sem graphics/dkms) ───────────────────
echo "→ Adicionando repositório ROCm $ROCM_VERSION..."
sudo tee /etc/apt/sources.list.d/rocm.list << EOF
deb [arch=amd64 signed-by=/etc/apt/keyrings/rocm.gpg] https://repo.radeon.com/rocm/apt/${ROCM_VERSION} noble main
EOF

# Pin para não conflitar com pacotes Ubuntu
sudo tee /etc/apt/preferences.d/rocm-pin-600 << EOF
Package: *
Pin: release o=repo.radeon.com
Pin-Priority: 600
EOF

sudo apt update

# ── Instalar ROCm userspace (sem amdgpu-dkms) ────────────────────────────────
# rocm instala: rocminfo, rocm-smi, HIP runtime, OpenCL, bibliotecas compute
echo "→ Instalando ROCm userspace (pode demorar vários minutos)..."
sudo apt install -y rocm

# ── Grupos de acesso à GPU ────────────────────────────────────────────────────
echo "→ Adicionando usuário aos grupos render e video..."
sudo usermod -a -G render,video "$LOGNAME"

# ── Variáveis de ambiente ROCm ────────────────────────────────────────────────
# Garantir que /opt/rocm/bin está no PATH do sistema
if ! grep -q "rocm" /etc/profile.d/rocm.sh 2>/dev/null; then
  sudo tee /etc/profile.d/rocm.sh << 'EOF'
export PATH=/opt/rocm/bin:$PATH
export LD_LIBRARY_PATH=/opt/rocm/lib:${LD_LIBRARY_PATH:-}
EOF
fi

echo ""
echo "✓ ROCm $ROCM_VERSION (userspace) instalado!"
echo ""
echo "  ⚠️  REBOOT necessário para aplicar grupos (render, video)."
echo "     Após reiniciar, verifique com:"
echo "       rocm-smi"
echo "       rocminfo | grep 'Marketing Name'"
