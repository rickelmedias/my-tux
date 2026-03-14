# My Tux

> Automated personal development environment setup for Ubuntu 24.04.

```
                         ┌─────────────────────────────────┐
                         │           my-tux (main)         │
                         │        ← documentation →        │
                         └────────────┬────────────────────┘
                                      │
                   ┌──────────────────┴──────────────────┐
                   │                                     │
       ┌───────────▼────────────┐           ┌────────────▼───────────┐
       │   operational-system   │           │          wsl           │
       │   Ubuntu 24.04 bare    │           │  Ubuntu 24.04 on WSL2  │
       │        metal           │           │  (Windows host)        │
       └────────────────────────┘           └────────────────────────┘
```

Choose your branch based on your environment and run `./bootstrap.sh` — it handles everything.

---

## Hardware & OS

| | |
|---|---|
| CPU | AMD Ryzen 7 7700X |
| GPU | AMD RX 7800 XT (gfx1101, RDNA3) |
| OS | Ubuntu 24.04.3 LTS (Noble Numbat) |

---

## Quick Start

```bash
# 1. Clone and enter the repo
git clone https://github.com/rickelmedias/my-tux
cd my-tux

# 2. Switch to your branch
git checkout operational-system   # bare metal Ubuntu
# or
git checkout wsl                  # WSL2 on Windows

# 3. Configure your variables
cp .env.example .env
nano .env

# 4. Run
chmod +x bootstrap.sh scripts/*.sh
./bootstrap.sh
```

The script is **idempotent** — safe to run multiple times. State is saved in `~/.bootstrap_state` and execution resumes automatically after interruptions.

---

## What's installed in both branches

| Step | Description |
|---|---|
| `00-nvim-unstable` | Neovim unstable/dev build (optional, set `INSTALL_NVIM_UNSTABLE=true` in `.env`) |
| `01-packages` | Core system packages: build tools, neovim, stow, ripgrep, bat, fd, htop, jq, etc. |
| `02-zsh` | ZSH + Oh My ZSH + Powerlevel10k theme + MesloLGS NF fonts |
| `03-conda` | Miniconda3 (base env not auto-activated) |
| `04-docker` | Docker Engine CE + Compose plugin |
| `05-rocm` | AMD ROCm 7.2 |
| `06-pytorch` | PyTorch with ROCm — official AMD wheels (Python 3.10 or 3.11) |
| `07-mise` | Mise + Java 21 (Temurin), Node LTS, Go, Rust, Maven |
| `08-git` | Global Git config + SSH key generation + git-delta |
| `09-dotfiles` | Dotfiles symlinked via GNU Stow |

---

## Differences between branches

### `operational-system` — bare metal Ubuntu

| Step | Detail |
|---|---|
| `01-packages` | Includes `gnome-tweaks`, `gnome-shell-extension-manager`, `xclip`, `dconf-cli` |
| `02-zsh` | Installs Monokai Pro theme on GNOME Terminal via Gogh |
| `05-rocm` | Installs ROCm 7.2 via package manager (`apt install rocm`) — **full reboot required** |

Post-install manual steps:
1. Terminal → Preferences → Profile → Font: `MesloLGS NF Regular`
2. `p10k configure` to set up the prompt
3. Add SSH key to GitHub: `cat ~/.ssh/id_ed25519.pub`
4. GNOME Tweaks → Appearance → Themes/Icons
5. Extensions: Dash to Dock, User Themes (via Extension Manager)

---

### `wsl` — WSL2 on Windows

| Step | Detail |
|---|---|
| `01-packages` | GNOME-specific packages excluded (not available in WSL) |
| `02-zsh` | Gogh theme skipped — configure font in Windows Terminal instead |
| `05-rocm` | Installs via `amdgpu-install --usecase=wsl,rocm --no-dkms` — **requires `wsl --shutdown` instead of reboot** |

Pre-requisite (Windows side): install [AMD Adrenalin Edition 26.1.1+](https://www.amd.com/en/support) before running the bootstrap.

Post-install manual steps:
1. Windows Terminal → Settings → Ubuntu profile → Appearance → Font: `MesloLGS NF Regular`
2. `p10k configure` to set up the prompt
3. Add SSH key to GitHub: `cat ~/.ssh/id_ed25519.pub`
4. Verify GPU: `rocminfo | grep 'Marketing Name'`

---

## Dotfiles (GNU Stow)

Each subdirectory in `dotfiles/` is a Stow package that maps directly to `$HOME`:

```
dotfiles/
├── zsh/
│   ├── .zshrc
│   └── .p10k.zsh
└── nvim/
    └── .config/nvim/
        ├── init.lua              # lazy.nvim
        └── lua/plugins/
            ├── colorscheme.lua   # Monokai Pro
            ├── telescope.lua     # + fzf-native
            ├── treesitter.lua
            └── extras.lua        # neo-tree, lualine, gitsigns
```

```bash
# Re-apply after changes
cd dotfiles && stow --restow --target="$HOME" nvim zsh

# Remove a package
stow -D --target="$HOME" nvim

# Add new dotfiles (e.g. tmux)
mkdir -p dotfiles/tmux
cp ~/.tmux.conf dotfiles/tmux/.tmux.conf
cd dotfiles && stow --target="$HOME" tmux
```

---

## Neovim errors

The error `vim.schedule callback: vim/keymap.lua:0: rhs: expected string|function` is caused by a plugin (likely gitsigns) mapping a key with a `nil` value.

- Check `~/.config/nvim/lua/plugins/extras.lua:72-77`
- Does not affect general Neovim functionality
- Permanent fix: set `INSTALL_NVIM_UNSTABLE=true` in `.env`

---

## Tool choices

**mise over asdf** — written in Rust, significantly faster, compatible with `.tool-versions`, actively maintained.

**lazy.nvim over Packer** — Packer was archived in August 2023. lazy.nvim has true lazy loading, better UI, and faster startup.

**GNU Stow** — no dependencies beyond Perl (pre-installed on Ubuntu). Simple symlink management that works with any VCS.

---

## Contributing

Issues and PRs are welcome. If you run this on a different AMD GPU or Ubuntu version, please share your experience.

## License

MIT
