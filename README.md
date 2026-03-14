# My Tux — wsl

Automated setup for **Ubuntu 24.04 on WSL2** (Windows Subsystem for Linux).

> For bare metal Ubuntu, switch to the [`operational-system`](../../tree/operational-system) branch.  
> For an overview of both branches, see [`main`](../../tree/main).

---

## Hardware & host

| Component | Spec |
|---|---|
| CPU | AMD Ryzen 7 7700X |
| GPU | AMD RX 7800 XT (gfx1101, RDNA3) |
| Host OS | Windows (with WSL2) |
| WSL distro | Ubuntu 24.04 LTS (Noble Numbat) |

---

## Pre-requisites (Windows side — before running anything)

These must be done on Windows **before** running the bootstrap:

1. **Install WSL2 with Ubuntu 24.04**
   ```powershell
   wsl --install -d Ubuntu-24.04
   ```

2. **Install AMD Adrenalin Edition 26.1.1+**  
   Download from [amd.com/en/support](https://www.amd.com/en/support).  
   This is the Windows GPU driver that exposes the GPU to WSL via `dxgkrnl`.  
   **Restart Windows after installing.**

3. **Verify WSL2 (not WSL1)**
   ```powershell
   wsl --list --verbose   # VERSION column must show 2
   ```

---

## Usage

Inside Ubuntu on WSL:

```bash
git clone https://github.com/rickelmedias/my-tux
cd my-tux
git checkout wsl
cp .env.example .env
nano .env
chmod +x bootstrap.sh scripts/*.sh
./bootstrap.sh
```

After ROCm installs, the script will pause and ask you to restart WSL. In PowerShell:

```powershell
wsl --shutdown
wsl   # reopen Ubuntu
```

Then resume:

```bash
./bootstrap.sh   # continues automatically from where it stopped
```

The script is **idempotent** — state is saved in `~/.bootstrap_state`. Safe to run multiple times.

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

> GNOME-specific packages (`gnome-tweaks`, `gnome-shell-extension-manager`, `xclip`, `dconf-cli`) are excluded — they are not available or useful in WSL.

`bat` is installed as `batcat` on Ubuntu — the script creates a `~/.local/bin/bat` symlink automatically.

### Step 02 — ZSH + Oh My ZSH + Powerlevel10k

- Sets ZSH as the default shell via `chsh`
- Installs [Oh My ZSH](https://ohmyz.sh/) non-interactively
- Installs plugins: `zsh-autosuggestions`, `zsh-syntax-highlighting`, `zsh-completions`
- Installs [Powerlevel10k](https://github.com/romkatv/powerlevel10k) theme
- Downloads MesloLGS NF fonts (Regular, Bold, Italic, Bold Italic) to `~/.local/share/fonts`

> GNOME Terminal theme (Gogh) is skipped — there is no GNOME Terminal in WSL.  
> Configure the font in **Windows Terminal**: Settings → Ubuntu profile → Appearance → Font face → `MesloLGS NF Regular`.

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

### Step 05 — AMD ROCm 7.2 for WSL ⚠️ WSL restart required

ROCm is installed via `amdgpu-install` with the `wsl` usecase — **no kernel driver (DKMS) is installed**. The GPU is exposed to WSL by the Windows Adrenalin driver via `dxgkrnl`.

- Downloads `amdgpu-install_7.2.70200-1_all.deb` from `repo.radeon.com`
- Installs the `amdgpu-install` script package
- Runs: `sudo amdgpu-install -y --usecase=wsl,rocm --no-dkms`
  - Installs: rocminfo, rocm-smi, HIP runtime, OpenCL, compute libraries
  - Does **not** install `amdgpu-dkms` (kernel driver — not needed and not supported in WSL)
- Adds user to `render` and `video` groups

After this step, the bootstrap pauses. You must restart WSL for the group changes to take effect:

```powershell
# In Windows PowerShell:
wsl --shutdown
wsl
```

Then run `./bootstrap.sh` again to continue.

Verify GPU access after restart:
```bash
rocminfo | grep 'Marketing Name'
rocm-smi
```

### Step 06 — PyTorch with ROCm

Requires Miniconda (step 03) and ROCm (step 05 + WSL restart).

Creates conda environments and installs official AMD ROCm wheels from `repo.radeon.com`:

| `PYTHON_VERSIONS` | Conda env | PyTorch | torchvision | torchaudio | triton |
|---|---|---|---|---|---|
| `3.10` | `rocm-env` | 2.5.1+rocm7.0.2 | 0.22.1 | 2.7.1 | 3.1.0 |
| `3.11` | `rocm-env-311` | 2.7.1+rocm7.0.2 | 0.23.0 | 2.7.1 | 3.3.1 |
| `both` | both above | both above | | | |

Set `PYTHON_VERSIONS` in `.env` to skip the interactive prompt.

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

1. **Terminal font:** Windows Terminal → Settings → Ubuntu profile → Appearance → Font face → `MesloLGS NF Regular`
2. **Prompt:** run `p10k configure` to reconfigure Powerlevel10k
3. **GitHub SSH:** `cat ~/.ssh/id_ed25519.pub` → [github.com/settings/ssh/new](https://github.com/settings/ssh/new)
4. **Verify GPU:** `rocminfo | grep 'Marketing Name'`

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
PYTHON_VERSIONS="3.10"        # 3.10 | 3.11 | both
INSTALL_NVIM_UNSTABLE="false" # true | false
```
