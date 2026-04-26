#!/usr/bin/env bash
# Script 05 - AMD ROCm 7.2
# Suporta WSL e bare metal na mesma base.
set -euo pipefail

BOOTSTRAP_TARGET="${BOOTSTRAP_TARGET:-$(grep -qi "microsoft" /proc/version 2>/dev/null && echo wsl || echo operational-system)}"
ROCM_VERSION="7.2"
AMDGPU_DEB="amdgpu-install_7.2.70200-1_all.deb"
AMDGPU_URL="https://repo.radeon.com/amdgpu-install/${ROCM_VERSION}/ubuntu/noble/${AMDGPU_DEB}"

if command -v rocm-smi &>/dev/null; then
  echo "→ ROCm já instalado."
  rocm-smi --showdriverversion 2>/dev/null || rocm-smi 2>/dev/null || true
  exit 0
fi

install_rocm_wsl() {
  echo "→ Baixando amdgpu-install ${ROCM_VERSION}..."
  wget -q --show-progress -O "/tmp/${AMDGPU_DEB}" "${AMDGPU_URL}"

  echo "→ Instalando pacote amdgpu-install..."
  sudo apt update -qq
  sudo apt install -y "/tmp/${AMDGPU_DEB}"
  rm -f "/tmp/${AMDGPU_DEB}"

  echo "→ Instalando ROCm para WSL (sem DKMS)..."
  sudo amdgpu-install -y --usecase=wsl,rocm --no-dkms
}

install_rocm_bare_metal() {
  echo "→ Verificando driver amdgpu no kernel..."
  echo "  Kernel: $(uname -r)"

  if lsmod | grep -q "^amdgpu"; then
    echo "  ✓ amdgpu já carregado no kernel — não é necessário o DKMS da AMD."
  else
    echo "  ⚠️  amdgpu não carregado. Tentando carregar..."
    sudo modprobe amdgpu || {
      echo "  ✗ Falha ao carregar amdgpu. Verifique se a GPU está conectada."
      exit 1
    }
  fi

  echo "→ Adicionando chave GPG da AMD..."
  sudo mkdir -p /etc/apt/keyrings
  wget -qO - https://repo.radeon.com/rocm/rocm.gpg.key \
    | gpg --dearmor \
    | sudo tee /etc/apt/keyrings/rocm.gpg > /dev/null

  echo "→ Adicionando repositório ROCm ${ROCM_VERSION}..."
  sudo tee /etc/apt/sources.list.d/rocm.list > /dev/null <<EOF
deb [arch=amd64 signed-by=/etc/apt/keyrings/rocm.gpg] https://repo.radeon.com/rocm/apt/${ROCM_VERSION} noble main
EOF

  sudo tee /etc/apt/preferences.d/rocm-pin-600 > /dev/null <<EOF
Package: *
Pin: release o=repo.radeon.com
Pin-Priority: 600
EOF

  sudo apt update
  echo "→ Instalando ROCm userspace (pode demorar vários minutos)..."
  sudo apt install -y rocm

  if ! grep -q "rocm" /etc/profile.d/rocm.sh 2>/dev/null; then
    sudo tee /etc/profile.d/rocm.sh > /dev/null <<'EOF'
export PATH=/opt/rocm/bin:$PATH
export LD_LIBRARY_PATH=/opt/rocm/lib:${LD_LIBRARY_PATH:-}
EOF
  fi
}

if [[ "$BOOTSTRAP_TARGET" == "wsl" ]]; then
  if ! grep -qi "microsoft" /proc/version 2>/dev/null; then
    echo "✗ BOOTSTRAP_TARGET=wsl definido, mas o ambiente atual não parece WSL."
    exit 1
  fi
  install_rocm_wsl
else
  install_rocm_bare_metal
fi

echo "→ Adicionando usuário aos grupos render e video..."
sudo usermod -a -G render,video "$LOGNAME"

echo ""
if [[ "$BOOTSTRAP_TARGET" == "wsl" ]]; then
  echo "✓ ROCm ${ROCM_VERSION} instalado para WSL!"
  echo ""
  echo "  ⚠️  Feche e reabra o WSL para aplicar os grupos (render, video)."
else
  echo "✓ ROCm ${ROCM_VERSION} instalado para bare metal!"
  echo ""
  echo "  ⚠️  Reinicie o sistema para aplicar os grupos (render, video)."
fi
echo "     Após isso, verifique com: rocm-smi && rocminfo | grep 'Marketing Name'"
