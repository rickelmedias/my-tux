#!/usr/bin/env bash
# =============================================================================
# Linux Bootstrap - Ubuntu 24.04 LTS
# Hardware: AMD Ryzen 7 7700X + RX 7800 XT (gfx1101, RDNA3)
# =============================================================================
set -euo pipefail

BOOTSTRAP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STATE_FILE="$HOME/.bootstrap_state"

# Log dentro do projeto — não suja o home
LOG_DIR="$BOOTSTRAP_DIR/.logs"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/bootstrap-$(date +%Y%m%d_%H%M%S).log"
ln -sf "$LOG_FILE" "$LOG_DIR/latest.log"  # .logs/latest.log → sempre o mais recente

# ── Colors ────────────────────────────────────────────────────────────────────
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
BLUE='\033[0;34m'; BOLD='\033[1m'; NC='\033[0m'

log()    { echo -e "${GREEN}[✓]${NC} $*" | tee -a "$LOG_FILE"; }
info()   { echo -e "${BLUE}[→]${NC} $*" | tee -a "$LOG_FILE"; }
warn()   { echo -e "${YELLOW}[!]${NC} $*" | tee -a "$LOG_FILE"; }
error()  { echo -e "${RED}[✗]${NC} $*" | tee -a "$LOG_FILE"; exit 1; }
header() { echo -e "\n${BOLD}${BLUE}══════════════════════════════════════${NC}"; \
            echo -e "${BOLD}${BLUE}  $*${NC}"; \
            echo -e "${BOLD}${BLUE}══════════════════════════════════════${NC}\n"; }

# ── State management — bitmask binário de 2 bytes ─────────────────────────────
# Cada step ocupa 1 bit. Arquivo final: 2 bytes opacos no disco.
# Sem este script, o arquivo é ilegível — só números binários sem contexto.
declare -A _STEP_BIT=(
  ["01-packages"]=0
  ["02-zsh"]=1
  ["03-conda"]=2
  ["04-docker"]=3
  ["05-rocm"]=4
  ["05-rocm-reboot"]=5
  ["06-pytorch"]=6
  ["07-mise"]=7
  ["08-git"]=8
  ["09-dotfiles"]=9
)

_state_val() {
  python3 - <<PY
import os, struct
f = "${STATE_FILE}"
if not os.path.exists(f):
    print(0)
else:
    with open(f, 'rb') as fh:
        d = fh.read(2)
        print(struct.unpack('<H', d.ljust(2, b'\x00'))[0] if d else 0)
PY
}

is_done() {
  local bit="${_STEP_BIT[$1]:-99}"
  [[ "$bit" == "99" ]] && return 1
  local val; val=$(_state_val)
  python3 -c "import sys; sys.exit(0 if ($val >> $bit) & 1 else 1)"
}

mark_done() {
  local bit="${_STEP_BIT[$1]:-99}"
  [[ "$bit" == "99" ]] && return 0
  local val; val=$(_state_val)
  python3 - <<PY
import struct
val = $val | (1 << $bit)
with open("${STATE_FILE}", 'wb') as f:
    f.write(struct.pack('<H', val))
PY
}

# ── Pre-flight checks ─────────────────────────────────────────────────────────
preflight() {
  header "Linux Bootstrap - Pre-flight checks"

  local distro
  distro=$(lsb_release -rs 2>/dev/null || echo "unknown")
  if [[ "$distro" != "24.04" ]]; then
    warn "Este script foi feito para Ubuntu 24.04. Versão detectada: $distro"
  fi

  local codename
  codename=$(lsb_release -cs 2>/dev/null || echo "unknown")
  if [[ "$codename" != "noble" ]]; then
    error "Este script requer Ubuntu 24.04 (Noble Numbat)"
  fi
  log "Ubuntu Noble detectado ✓"

  local kernel; kernel=$(uname -r)
  info "Kernel: $kernel"

  if lspci | grep -qi "AMD/ATI.*RX 7800"; then
    log "RX 7800 XT detectada ✓ (gfx1101, RDNA3 — suportada pelo ROCm 7.2)"
  elif lspci | grep -qi "AMD"; then
    warn "GPU AMD detectada (verifique suporte ROCm em https://rocm.docs.amd.com)"
  fi

  echo ""
  info "Log: $LOG_FILE"
  info "Estado: $STATE_FILE (bitmask binário)"
  echo ""
}

# ── Checkpoint de reboot ───────────────────────────────────────────────────────
checkpoint_reboot() {
  mark_done "$1"
  echo ""
  warn "╔══════════════════════════════════════════════════════╗"
  warn "║  REBOOT NECESSÁRIO para continuar                    ║"
  warn "║  Após reiniciar, rode: ./bootstrap.sh                ║"
  warn "║  O script continuará de onde parou automaticamente.  ║"
  warn "╚══════════════════════════════════════════════════════╝"
  echo ""
  read -rp "Reiniciar agora? [s/N]: " confirm
  if [[ "$confirm" =~ ^[sS]$ ]]; then
    sudo reboot
  else
    info "Reinicie manualmente e rode ./bootstrap.sh novamente."
    exit 0
  fi
}

# ── Executar script de etapa ──────────────────────────────────────────────────
run_step() {
  local name="$1"
  local script="$BOOTSTRAP_DIR/scripts/$2"

  if is_done "$name"; then
    log "[$name] já concluído, pulando..."
    return 0
  fi

  header "$name"
  if bash "$script"; then
    mark_done "$name"
    log "[$name] concluído com sucesso!"
  else
    error "[$name] falhou. Verifique $LOG_DIR/latest.log"
  fi
}

# ── MAIN ──────────────────────────────────────────────────────────────────────
main() {
  preflight

  if [[ -f "$BOOTSTRAP_DIR/.env" ]]; then
    source "$BOOTSTRAP_DIR/.env"
    if [[ "${INSTALL_NVIM_UNSTABLE:-false}" == "true" ]]; then
      run_step "00-nvim-unstable" "00-nvim-unstable.sh"
    fi
  fi

  run_step "01-packages"    "01-packages.sh"
  run_step "02-zsh"         "02-zsh.sh"
  run_step "03-conda"       "03-conda.sh"
  run_step "04-docker"      "04-docker.sh"

  if ! is_done "05-rocm"; then
    run_step "05-rocm" "05-rocm.sh"
    checkpoint_reboot "05-rocm-reboot"
  fi

  run_step "06-pytorch"     "06-pytorch.sh"
  run_step "07-mise"        "07-mise.sh"
  run_step "08-git"         "08-git.sh"
  run_step "09-dotfiles"    "09-dotfiles.sh"

  header "Bootstrap completo!"
  log "Ambiente de desenvolvimento configurado com sucesso!"
  echo ""
  info "Próximos passos manuais:"
  echo "  1. Terminal → Preferências → Fonte: MesloLGS NF Regular"
  echo "  2. Adicione sua chave SSH ao GitHub: cat ~/.ssh/id_ed25519.pub"
  echo "  3. Verifique GPU: rocm-smi && rocminfo | grep 'Marketing Name'"
  echo "  4. GNOME Tweaks → Aparência → Temas/Ícones"
  echo ""
  info "Logs disponíveis em: $LOG_DIR/"
  echo ""
}

main "$@"
