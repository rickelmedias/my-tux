# My Tux

Complete and automated personal development environment setup.

**Target Hardware:** AMD Ryzen 7 7700X + RX 7800 XT (gfx1101, RDNA3)
**OS:** Ubuntu 24.04.3 LTS (Noble Numbat)

## Usage

1. **Configure variables**:

```bash
cp .env.example .env
nano .env               # Fill in your information
```

2. **Run bootstrap**:

```bash
git clone [https://github.com/rickelmedias/my-tux.git](https://github.com/rickelmedias/my-tux.git)
cd my-tux
chmod +x bootstrap.sh scripts/*.sh
./bootstrap.sh
```

3. **After reboot** (required after ROCm installation):

```bash
./bootstrap.sh          # Automatically resumes
```

*The script is **idempotent** — it can be safely run multiple times. It saves its state in `~/.bootstrap_state` and resumes from where it left off after reboots.*

---

## Regarding Neovim errors

1. It might be an error due to not using the latest version, so Lazy cannot download all dependencies.
2. The error `vim.schedule callback: vim/keymap.lua:0: rhs: expected string|function` appears in some files and is related to a plugin (likely gitsigns) attempting to map a key with a `nil` value.

**Solutions**:

* Check `~/.config/nvim/lua/plugins/extras.lua:72-77`
* The mapping might be referencing a non-existent function.
* It does not impact Neovim's general functionality.
* Permanent solution: enable `INSTALL_NVIM_UNSTABLE=true` in `.env`.

---

## What is installed

| Step | Description |
| --- | --- |
| `00-nvim-unstable` | Installs the dev/unstable version (optional, via `.env`) |
| `01-packages` | System packages: build tools, neovim, stow, ripgrep, bat, fd, etc. |
| `02-zsh` | ZSH + Oh My ZSH + Powerlevel10k + MesloLGS NF fonts |
| `03-conda` | Miniconda3 (base not activated by default) |
| `04-docker` | Docker Engine CE + Compose plugin |
| `05-rocm` | AMD ROCm 7.2 via package manager (**reboot required**) |
| `06-pytorch` | PyTorch 2.5.1 or 2.7.1 with ROCm (official AMD wheels) |
| `07-mise` | Mise + Java 21 (Temurin), Node LTS, Go, Rust, Maven |
| `08-git` | Global Git config + SSH key + git-delta |
| `09-dotfiles` | Dotfiles symlinking via **GNU Stow** |

---

## Important Notes — ROCm + RX 7800 XT

* The **RX 7800 XT (gfx1101)** is **officially supported** by ROCm 7.2
* Supported only on **Ubuntu 24.04.3** — specific point release version.
* This script uses the **package manager method** (recommended by AMD since ROCm 7.x).
* The `amdgpu-install` via `.deb` method has been removed from official documentation.


* After installing ROCm, a **reboot is mandatory**.
* The `HSA_OVERRIDE_GFX_VERSION` variable is **not required** for the RX 7800 XT (gfx1101 is natively supported).
* Verify after reboot:

```bash
rocm-smi          # GPU status
rocminfo          # Detailed information
hipinfo           # Verify HIP runtime
```

---

## Project Structure

```
my-tux/
├── bootstrap.sh            # Main orchestrator
├── .env.example            # Configuration template
├── .env                    # Your configs (create based on .example)
├── scripts/
│   ├── 00-nvim-unstable.sh
│   ├── 01-packages.sh
│   ├── 02-zsh.sh
│   ├── 03-conda.sh
│   ├── 04-docker.sh
│   ├── 05-rocm.sh          # ROCm 7.2 (package manager)
│   ├── 06-pytorch.sh       # PyTorch wheels AMD
│   ├── 07-mise.sh
│   ├── 08-git.sh
│   └── 09-dotfiles.sh      # GNU Stow
└── dotfiles/               # Managed via GNU Stow
    ├── zsh/
    │   ├── .zshrc
    │   └── .p10k.zsh
    └── nvim/
        └── .config/nvim/
            ├── init.lua    # lazy.nvim
            └── lua/plugins/
                ├── colorscheme.lua   # Monokai Pro
                ├── telescope.lua     # + fzf-native
                ├── treesitter.lua
                └── extras.lua        # neo-tree, lualine, gitsigns
```

---

## Dotfiles — GNU Stow

[GNU Stow](https://www.gnu.org/software/stow/) manages symlinks automatically. Each subdirectory in `dotfiles/` is a "package":

```bash
# Install all dotfiles
cd dotfiles && stow --target="$HOME" zsh nvim

# Remove symlinks for a package
stow -D --target="$HOME" nvim

# Update after changes
stow --restow --target="$HOME" nvim
```

To add new dotfiles (e.g., tmux):

```bash
mkdir -p dotfiles/tmux
cp ~/.tmux.conf dotfiles/tmux/.tmux.conf
cd dotfiles && stow --target="$HOME" tmux
```

---

## Tool Choices

### Why `mise` instead of `asdf`?

* Written in **Rust** (much faster).
* Compatible with asdf's `.tool-versions`.
* Actively maintained with a vibrant roadmap.
* Simpler installation, fewer dependencies.

### Why `lazy.nvim` instead of `Packer`?

* Packer was **archived** in August 2023 — no further updates.
* lazy.nvim is the modern replacement: true lazy loading, better UI, faster.

### Why `GNU Stow`?

* No dependencies beyond Perl (pre-installed).
* Simple: just creates/removes symlinks.
* Works perfectly with any VCS (git pull = updated dotfiles).

---

## Manual Steps (post-script)

1. **Terminal:** Preferences → Profile → Text → Font: `MesloLGS NF Regular`.
2. **Powerlevel10k:** `p10k configure` (if you wish to reconfigure).
3. **GitHub SSH:** Copy `~/.ssh/id_ed25519.pub` → [github.com/settings/ssh](https://github.com/settings/ssh/new).
4. **GNOME Tweaks:** Themes and icons (download manually from [gnome-look.org](https://www.gnome-look.org)).
5. **Extensions:** Dash to Dock, User Themes (via Extension Manager).

---

## Contributing

Issues and PRs are welcome! If you use this setup on another AMD GPU or Ubuntu version, please share your experience.

## License

MIT License - feel free to use and modify.
