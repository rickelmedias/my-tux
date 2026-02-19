#!/usr/bin/env bash
# Script 08 - Git global config + SSH key
set -euo pipefail

BOOTSTRAP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ENV_FILE="$BOOTSTRAP_DIR/.env"

# ── Carregar .env se existir ──────────────────────────────────────────────────
if [[ -f "$ENV_FILE" ]]; then
  echo "→ Carregando configurações de $ENV_FILE..."
  set -a
  source "$ENV_FILE"
  set +a
fi

# ── Configurações globais ─────────────────────────────────────────────────────
echo "→ Configurando Git..."

# Usar .env ou solicitar input
if [[ -z "$(git config --global user.name 2>/dev/null)" ]]; then
  if [[ -n "${GIT_USER_NAME:-}" ]]; then
    git config --global user.name "$GIT_USER_NAME"
    echo "  Nome configurado (via .env): $GIT_USER_NAME"
  else
    read -rp "  Seu nome para o Git: " git_name
    git config --global user.name "$git_name"
  fi
fi

if [[ -z "$(git config --global user.email 2>/dev/null)" ]]; then
  if [[ -n "${GIT_USER_EMAIL:-}" ]]; then
    git config --global user.email "$GIT_USER_EMAIL"
    echo "  E-mail configurado (via .env): $GIT_USER_EMAIL"
  else
    read -rp "  Seu e-mail para o Git: " git_email
    git config --global user.email "$git_email"
  fi
fi

# Configurações que não dependem de input
git config --global init.defaultBranch    main
git config --global pull.rebase           false
git config --global core.editor          "nvim -c 'startinsert'"
git config --global core.autocrlf         input

# git-delta (diffs bonitos)
if command -v delta &>/dev/null; then
  git config --global pager.diff          delta
  git config --global pager.log           delta
  git config --global pager.show          delta
  git config --global interactive.diffFilter "delta --color-only"
  git config --global delta.navigate      true
  git config --global delta.light         false
  git config --global delta.line-numbers  true
  git config --global delta.syntax-theme  "Monokai Extended"
  echo "→ git-delta configurado."
fi

# Aliases úteis
git config --global alias.st   status
git config --global alias.co   checkout
git config --global alias.br   branch
git config --global alias.lg   "log --oneline --graph --decorate --all"
git config --global alias.undo "reset HEAD~1 --mixed"

echo ""
echo "✓ Git configurado:"
git config --global --list | grep -E "user\.|core\.|init\."

# ── SSH Key ────────────────────────────────────────────────────────────────────
SSH_KEY="$HOME/.ssh/id_ed25519"

if [[ ! -f "$SSH_KEY" ]]; then
  echo ""
  echo "→ Gerando chave SSH ed25519..."
  local_email=$(git config --global user.email)
  ssh-keygen -t ed25519 -C "$local_email" -f "$SSH_KEY" -N ""
  eval "$(ssh-agent -s)"
  ssh-add "$SSH_KEY"
  echo ""
  echo "  ✓ Chave SSH gerada. Adicione a chave pública ao GitHub:"
  echo "  ──────────────────────────────────────────────────────"
  cat "${SSH_KEY}.pub"
  echo "  ──────────────────────────────────────────────────────"
  echo "  https://github.com/settings/ssh/new"
else
  echo ""
  echo "→ Chave SSH já existe: $SSH_KEY"
  echo "  Chave pública:"
  cat "${SSH_KEY}.pub"
fi
