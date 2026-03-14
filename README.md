# My Tux

> Automated personal development environment setup for Ubuntu 24.04.

![banner](bg.jpg)

---

```mermaid
flowchart TD
    main["🐧 my-tux (main)\ndocumentation & entry point"]

    main --> os["operational-system\nUbuntu 24.04 bare metal"]
    main --> wsl["wsl\nUbuntu 24.04 on WSL2\nWindows host"]

    os --> os_pre["Pre-requisites\nUbuntu 24.04.3 LTS\nsudo access"]
    os --> os_steps["Steps\n00 nvim-unstable (optional)\n01 packages + GNOME tools\n02 zsh + Gogh theme\n03 conda\n04 docker\n05 ROCm 7.2 → reboot\n06 PyTorch ROCm wheels\n07 mise + runtimes\n08 git + SSH key\n09 dotfiles (stow)"]
    os --> os_post["Post-install\nSet MesloLGS NF in Terminal\np10k configure\nAdd SSH key to GitHub\nGNOME Tweaks + Extensions"]

    wsl --> wsl_pre["Pre-requisites (Windows)\nWSL2 + Ubuntu 24.04\nAdrenalin 26.1.1+ driver\nRestart Windows"]
    wsl --> wsl_steps["Steps\n00 nvim-unstable (optional)\n01 packages (no GNOME)\n02 zsh (no Gogh)\n03 conda\n04 docker\n05 ROCm 7.2 via amdgpu-install → wsl --shutdown\n06 PyTorch ROCm wheels\n07 mise + runtimes\n08 git + SSH key\n09 dotfiles (stow)"]
    wsl --> wsl_post["Post-install\nSet MesloLGS NF in Windows Terminal\np10k configure\nAdd SSH key to GitHub\nVerify GPU: rocminfo"]
```

---

## Hardware

| | |
|---|---|
| CPU | AMD Ryzen 7 7700X |
| GPU | AMD RX 7800 XT (gfx1101, RDNA3) |
| OS | Ubuntu 24.04.3 LTS (Noble Numbat) |

---

## Quick Start

```bash
git clone https://github.com/rickelmedias/my-tux
cd my-tux

# choose your branch
git checkout operational-system   # bare metal
git checkout wsl                  # WSL2 on Windows

cp .env.example .env
nano .env
chmod +x bootstrap.sh scripts/*.sh
./bootstrap.sh
```

---

## License

MIT
