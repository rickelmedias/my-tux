#!/usr/bin/env bash
# Script 07 - Mise (runtime version manager) + linguagens
# Mise é a escolha moderna: mais rápido que asdf, escrito em Rust, compatível
# com .tool-versions do asdf, e ativamente mantido.
# https://mise.jdx.dev
set -euo pipefail

# ── Instalar Mise ─────────────────────────────────────────────────────────────
if ! command -v mise &>/dev/null && [[ ! -f "$HOME/.local/bin/mise" ]]; then
  echo "→ Instalando Mise..."
  curl https://mise.run | sh
else
  echo "→ Mise já instalado: $(mise --version 2>/dev/null || echo 'versão desconhecida')"
fi

MISE="$HOME/.local/bin/mise"

# Garantir que mise está no PATH para este script
export PATH="$HOME/.local/bin:$PATH"

# ── Ativar mise no zshrc (se dotfiles ainda não foi instalado) ─────────────────
ZSHRC="$HOME/.zshrc"
if [[ -f "$ZSHRC" ]] && ! grep -q 'mise activate' "$ZSHRC"; then
  echo 'eval "$(~/.local/bin/mise activate zsh)"' >> "$ZSHRC"
  echo "→ Adicionado 'mise activate' ao ~/.zshrc"
fi

# ── Ativar para esta sessão ───────────────────────────────────────────────────
eval "$("$MISE" activate bash 2>/dev/null)" || true

# ── Plugin Maven (evitar erro de registro Aqua) ───────────────────────────────
echo "→ Adicionando plugin maven..."
"$MISE" plugin add maven 2>/dev/null || echo "  Plugin maven já existe."

# ── Instalar linguagens ───────────────────────────────────────────────────────
echo "→ Instalando linguagens via Mise..."
"$MISE" install \
  java@temurin-21 \
  node@lts \
  go@latest \
  rust@latest \
  maven@latest

echo "→ Definindo versões globais..."
"$MISE" use --global \
  java@temurin-21 \
  node@lts \
  go@latest \
  rust@latest \
  maven@latest

echo "→ Verificando instalações..."
"$MISE" doctor 2>/dev/null || true

echo ""
echo "✓ Mise e linguagens instaladas:"
"$MISE" list 2>/dev/null || true
