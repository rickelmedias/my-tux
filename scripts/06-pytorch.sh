#!/usr/bin/env bash
# Script 06 - PyTorch (WSL)
# No WSL, ROCm não está disponível. Instala PyTorch padrão (CPU).
# Para GPU AMD no WSL, use torch-directml separadamente se necessário.
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

PYTHON_VERSIONS="${PYTHON_VERSIONS:-3.10}"

setup_env() {
  local env_name="$1"
  local python_ver="$2"

  echo "→ Criando ambiente conda: $env_name (Python $python_ver)..."
  if ! "$CONDA_BIN" env list | grep -q "^$env_name "; then
    "$CONDA_BIN" create -n "$env_name" python="$python_ver" -y
  else
    echo "  Ambiente $env_name já existe."
  fi

  local pip_bin="$HOME/miniconda3/envs/$env_name/bin/pip"

  echo "→ Instalando PyTorch (CPU)..."
  "$pip_bin" install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cpu

  echo "→ Verificando instalação..."
  "$HOME/miniconda3/envs/$env_name/bin/python" -c "
import torch
print(f'  PyTorch: {torch.__version__}')
print(f'  CUDA disponível: {torch.cuda.is_available()} (esperado: False no WSL sem CUDA)')
"
}

case "$PYTHON_VERSIONS" in
  3.10) setup_env "pytorch-env"     "3.10" ;;
  3.11) setup_env "pytorch-env-311" "3.11" ;;
  both)
    setup_env "pytorch-env"     "3.10"
    setup_env "pytorch-env-311" "3.11"
    ;;
  *)
    echo "→ PYTHON_VERSIONS inválido: $PYTHON_VERSIONS. Usando 3.10."
    setup_env "pytorch-env" "3.10"
    ;;
esac

echo ""
echo "✓ PyTorch (CPU) instalado!"
echo "  Para GPU AMD no WSL, instale torch-directml manualmente:"
echo "    pip install torch-directml"
