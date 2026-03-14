#!/usr/bin/env bash
# Script 05 - ROCm (WSL)
# ROCm não é suportado no WSL. A GPU AMD é exposta via DirectML/CUDA (WSLg).
# Para aceleração de GPU no WSL, use PyTorch com suporte a DirectML ou CPU.
set -euo pipefail

echo ""
echo "  ⚠️  ROCm não é suportado no WSL."
echo "     A GPU é acessível via DirectML (Windows) — não via ROCm."
echo "     Etapa ignorada."
echo ""
exit 0
