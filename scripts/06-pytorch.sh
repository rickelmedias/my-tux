#!/usr/bin/env bash
# Script 06 - PyTorch com ROCm
set -euo pipefail

BOOTSTRAP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ENV_FILE="$BOOTSTRAP_DIR/.env"
CONDA_BIN="$HOME/miniconda3/bin/conda"

if [[ -f "$ENV_FILE" ]]; then
  set -a; source "$ENV_FILE"; set +a
fi

if [[ ! -f "$CONDA_BIN" ]]; then
  echo "✗ Miniconda não encontrado. Execute a etapa 03 primeiro."
  exit 1
fi

if ! command -v rocm-smi &>/dev/null; then
  echo "✗ ROCm não encontrado. Execute a etapa 05 primeiro e reinicie/reabra o ambiente."
  exit 1
fi

echo "→ Status da GPU:"
rocm-smi 2>/dev/null || true

setup_env() {
  local env_name="$1"
  local python_ver="$2"
  local wheel_dir="$3"

  echo ""
  echo "→ Criando ambiente conda: $env_name (Python $python_ver)..."
  if ! "$CONDA_BIN" env list | grep -q "^$env_name "; then
    "$CONDA_BIN" create -n "$env_name" python="$python_ver" -y
  else
    echo "  Ambiente $env_name já existe."
  fi

  local pip_bin="$HOME/miniconda3/envs/$env_name/bin/pip"

  echo "→ Baixando wheels PyTorch + ROCm..."
  mkdir -p "$wheel_dir"
  cd "$wheel_dir"

  download_if_missing() {
    local url="$1"
    local file="${url##*/}"
    local decoded_file="${file//%2B/+}"
    [[ -f "$decoded_file" ]] && { echo "  Wheel já baixado: $decoded_file"; return 0; }
    wget -q --show-progress -O "$decoded_file" "$url"
  }

  if [[ "$python_ver" == "3.10" ]]; then
    download_if_missing "https://repo.radeon.com/rocm/manylinux/rocm-rel-7.0.2/torch-2.5.1%2Brocm7.0.2.git07354c51-cp310-cp310-linux_x86_64.whl"
    download_if_missing "https://repo.radeon.com/rocm/manylinux/rocm-rel-7.0.2/torchvision-0.22.1%2Brocm7.0.2.git59a3e1f9-cp310-cp310-linux_x86_64.whl"
    download_if_missing "https://repo.radeon.com/rocm/manylinux/rocm-rel-7.0.2/torchaudio-2.7.1%2Brocm7.0.2.git95c61b41-cp310-cp310-linux_x86_64.whl"
    download_if_missing "https://repo.radeon.com/rocm/manylinux/rocm-rel-7.0.2/triton-3.1.0%2Brocm7.0.2.git1e26fcf7-cp310-cp310-linux_x86_64.whl"
  elif [[ "$python_ver" == "3.11" ]]; then
    download_if_missing "https://repo.radeon.com/rocm/manylinux/rocm-rel-7.0.2/torch-2.7.1%2Brocm7.0.2.git9015dfdf-cp311-cp311-linux_x86_64.whl"
    download_if_missing "https://repo.radeon.com/rocm/manylinux/rocm-rel-7.0.2/torchvision-0.23.0%2Brocm7.0.2.git824e8c87-cp311-cp311-linux_x86_64.whl"
    download_if_missing "https://repo.radeon.com/rocm/manylinux/rocm-rel-7.0.2/torchaudio-2.7.1%2Brocm7.0.2.git95c61b41-cp311-cp311-linux_x86_64.whl"
    download_if_missing "https://repo.radeon.com/rocm/manylinux/rocm-rel-7.0.2/triton-3.3.1%2Brocm7.0.2.git9c7bc0a3-cp311-cp311-linux_x86_64.whl"
  fi

  echo "→ Instalando PyTorch wheels..."
  "$pip_bin" install ./*.whl

  echo "→ Verificando instalação..."
  "$HOME/miniconda3/envs/$env_name/bin/python" -c "
import torch
print(f'  PyTorch: {torch.__version__}')
print(f'  ROCm disponível: {torch.cuda.is_available()}')
if torch.cuda.is_available():
    print(f'  GPU: {torch.cuda.get_device_name(0)}')
"
}

PYTHON_VERSIONS="${PYTHON_VERSIONS:-}"
if [[ -n "$PYTHON_VERSIONS" ]]; then
  echo "→ Usando configuração do .env: PYTHON_VERSIONS=$PYTHON_VERSIONS"
  choice="$PYTHON_VERSIONS"
else
  echo ""
  echo "Escolha os ambientes PyTorch:"
  echo "  3.10  - Python 3.10 (estável, recomendado)"
  echo "  3.11  - Python 3.11"
  echo "  both  - Ambos"
  read -rp "Opção [3.10/3.11/both]: " choice
  choice="${choice:-3.10}"
fi

case "$choice" in
  3.10|"") setup_env "rocm-env"     "3.10" "$HOME/rocm-wheels/310" ;;
  3.11)    setup_env "rocm-env-311" "3.11" "$HOME/rocm-wheels/311" ;;
  both)
    setup_env "rocm-env"     "3.10" "$HOME/rocm-wheels/310"
    setup_env "rocm-env-311" "3.11" "$HOME/rocm-wheels/311"
    ;;
  *)       setup_env "rocm-env"     "3.10" "$HOME/rocm-wheels/310" ;;
esac

echo ""
echo "✓ PyTorch com ROCm instalado!"
