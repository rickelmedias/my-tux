# My Tux

Automated setup for **Ubuntu 24.04** with support for both **bare metal Linux** and **Ubuntu on WSL2**.

> This repository now uses a single codebase.
> Environment-specific behavior is selected automatically by `bootstrap.sh`.

---

## Supported Environments

| Component | Spec |
|---|---|
| CPU | AMD Ryzen 7 7700X |
| GPU | AMD RX 7800 XT (gfx1101, RDNA3) |
| Bare metal | Ubuntu 24.04.3 LTS (Noble Numbat) |
| WSL | Windows 11 + WSL2 + Ubuntu 24.04 LTS |

---

## Pre-requisites

### Bare metal Ubuntu

- Fresh Ubuntu 24.04.3 LTS install
- Internet connection
- `sudo` access

### WSL2 on Windows 11

Before running the bootstrap inside Ubuntu:

1. Install WSL2 with Ubuntu 24.04
   ```powershell
   wsl --install -d Ubuntu-24.04
   ```
2. Install AMD Adrenalin Edition 26.1.1 or newer on Windows
   Download from [amd.com/en/support](https://www.amd.com/en/support).
3. Restart Windows after the driver install.
4. Verify the distro is running as WSL2
   ```powershell
   wsl --list --verbose
   ```

---

## Usage

```bash
git clone https://github.com/rickelmedias/my-tux
cd my-tux
cp .env.example .env
nano .env
chmod +x bootstrap.sh scripts/*.sh
./bootstrap.sh
```

The bootstrap auto-detects whether it is running on `wsl` or `operational-system`.

You can override detection manually if needed:

```bash
BOOTSTRAP_TARGET=wsl ./bootstrap.sh
BOOTSTRAP_TARGET=operational-system ./bootstrap.sh
```

The script is **idempotent**. State is saved in `~/.bootstrap_state`, so rerunning it resumes safely.

After ROCm installs:

- On bare metal, a full reboot is required.
- On WSL, close and reopen the distro:

```powershell
wsl --shutdown
wsl
```

Then resume:

```bash
./bootstrap.sh
```

---

## What gets installed

### Step 00 — Neovim Unstable *(optional)*

Only runs if `INSTALL_NVIM_UNSTABLE=true` is set in `.env`.

- Adds `ppa:neovim-ppa/unstable`
- Installs Neovim v0.12+ (dev build)
- Required for some modern plugins that fail on the stable apt version

### Step 01 — System packages

Runs `apt update && apt upgrade`, then installs:

| Package | Purpose |
|---|---|
| `build-essential` | gcc, make, etc. |
| `neovim` | text editor |
| `zsh` | shell |
| `stow` | dotfiles symlink manager |
| `git`, `git-delta` | version control + pretty diffs |
| `ripgrep`, `fd-find`, `bat` | modern CLI replacements for grep/find/cat |
| `htop`, `jq`, `tree` | system utilities |
| `openssh-client` | SSH |
| `curl`, `wget`, `unzip`, `zip`, `libgl1` | general utilities |

On bare metal, the bootstrap also installs `gnome-tweaks`, `gnome-shell-extension-manager`, `xclip`, and `dconf-cli`.
On WSL, those GNOME-specific packages are skipped automatically.

### Step 02 — ZSH + Oh My ZSH + Powerlevel10k

- Sets ZSH as the default shell via `chsh`
- Installs [Oh My ZSH](https://ohmyz.sh/) non-interactively
- Installs plugins: `zsh-autosuggestions`, `zsh-syntax-highlighting`, `zsh-completions`
- Installs [Powerlevel10k](https://github.com/romkatv/powerlevel10k) theme
- Downloads MesloLGS NF fonts (Regular, Bold, Italic, Bold Italic) to `~/.local/share/fonts`
- On bare metal, installs the **Monokai Pro** GNOME Terminal theme via [Gogh](https://gogh-co.github.io/Gogh/)
- On WSL, skips Gogh and expects font configuration in Windows Terminal

Configure the font after install:

- Bare metal: Terminal Preferences → Profile → Text → `MesloLGS NF Regular`
- WSL: Windows Terminal → Ubuntu profile → Appearance → `MesloLGS NF Regular`

### Step 03 — Miniconda3

- Downloads and installs Miniconda3 to `~/miniconda3`
- Initializes conda for ZSH
- Sets `auto_activate_base false` (base env is not activated on shell start)
- Accepts Anaconda ToS for the main and r channels

### Step 04 — Docker Engine

- Removes any conflicting packages (`docker.io`, `podman-docker`, etc.)
- Adds Docker's official apt repository with GPG key
- Installs: `docker-ce`, `docker-ce-cli`, `containerd.io`, `docker-buildx-plugin`, `docker-compose-plugin`
- Adds your user to the `docker` group

> In WSL, Docker runs without systemd by default. If `docker` commands fail after install, start the daemon manually with `sudo service docker start`, or enable [systemd in WSL](https://learn.microsoft.com/en-us/windows/wsl/systemd).

### Step 05 — AMD ROCm 7.2 ⚠️ restart required

The ROCm installation path depends on the detected environment.

Bare metal:

- Verifies `amdgpu` is available in the running kernel
- Adds the ROCm apt repository for Ubuntu Noble
- Installs `rocm` userspace packages only
- Creates `/etc/profile.d/rocm.sh` with `PATH` and `LD_LIBRARY_PATH`

WSL:

- Downloads `amdgpu-install_7.2.70200-1_all.deb`
- Installs `amdgpu-install`
- Runs `sudo amdgpu-install -y --usecase=wsl,rocm --no-dkms`
- Uses the Windows Adrenalin driver via `dxgkrnl`, so no Linux kernel DKMS driver is installed

Both paths:

- Add the user to `render` and `video`
- Require a restart before the PyTorch step

Verify after restart:

```bash
rocm-smi
rocminfo | grep 'Marketing Name'
```

### Step 06 — PyTorch with ROCm

Requires Miniconda (step 03) and ROCm (step 05 + restart).

Creates conda environments and installs official AMD ROCm wheels from `repo.radeon.com`:

| `PYTHON_VERSIONS` | Conda env | PyTorch | torchvision | torchaudio | triton |
|---|---|---|---|---|---|
| `3.10` | `rocm-env` | 2.5.1+rocm7.0.2 | 0.22.1 | 2.7.1 | 3.1.0 |
| `3.11` | `rocm-env-311` | 2.7.1+rocm7.0.2 | 0.23.0 | 2.7.1 | 3.3.1 |
| `both` | both above | both above | | | |

Set `PYTHON_VERSIONS` in `.env` to skip the interactive prompt, or leave it unset to choose interactively.

### Step 07 — Mise (runtime version manager)

- Installs [mise](https://mise.jdx.dev) to `~/.local/bin/mise`
- Adds `eval "$(~/.local/bin/mise activate zsh)"` to `~/.zshrc`
- Installs and sets as global:

| Tool | Version |
|---|---|
| Java | Temurin 21 (LTS) |
| Node.js | LTS |
| Go | latest |
| Rust | latest |
| Maven | latest |

### Step 08 — Git config + SSH key

- Sets `user.name` and `user.email` from `.env` (or prompts interactively)
- Global config: `init.defaultBranch=main`, `pull.rebase=false`, `core.editor=nvim`, `core.autocrlf=input`
- Configures `git-delta` as pager for diff/log/show with Monokai Extended theme
- Adds aliases: `st`, `co`, `br`, `lg`, `undo`
- Generates `~/.ssh/id_ed25519` if it doesn't exist and prints the public key

### Step 09 — Dotfiles (GNU Stow)

Symlinks all packages in `dotfiles/` to `$HOME`:

| Package | Files |
|---|---|
| `zsh` | `~/.zshrc`, `~/.p10k.zsh` |
| `nvim` | `~/.config/nvim/` (init.lua + plugins) |

If `~/.zshrc` already exists as a real file (not a symlink), it is backed up to `~/.zshrc.bak` before stowing.

---

## Post-install manual steps

1. Terminal font:
   Bare metal: Terminal Preferences → Profile → Text → `MesloLGS NF Regular`
   WSL: Windows Terminal → Ubuntu profile → Appearance → `MesloLGS NF Regular`
2. Prompt: run `p10k configure`
3. GitHub SSH: `cat ~/.ssh/id_ed25519.pub`
4. Verify GPU: `rocm-smi && rocminfo | grep 'Marketing Name'`
5. Bare metal only: configure themes/extensions with GNOME Tweaks and Extension Manager

---

## Neovim errors

The error `vim.schedule callback: vim/keymap.lua:0: rhs: expected string|function` is caused by a plugin (likely gitsigns) mapping a key with a `nil` value. It does not affect general functionality.

- Check `~/.config/nvim/lua/plugins/extras.lua:72-77`
- Permanent fix: set `INSTALL_NVIM_UNSTABLE=true` in `.env`

---

## `.env` reference

```bash
GIT_USER_NAME="Your Name"
GIT_USER_EMAIL="you@example.com"
PYTHON_VERSIONS="3.10"                 # 3.10 | 3.11 | both
INSTALL_NVIM_UNSTABLE="false"          # true | false
# BOOTSTRAP_TARGET="wsl"               # optional: wsl | operational-system
```
