# My Tux

> Automated personal development environment setup for Ubuntu 24.04.

![banner](bg.jpg)

---

My Tux is a fully automated personal development environment setup for Ubuntu 24.04. It installs and configures everything from scratch — shell, GPU drivers, runtimes, dotfiles — with a single command.

The project has two installation branches depending on where you're running Ubuntu. Choose the one that fits your setup, as shown in the flowchart below:

```mermaid
flowchart TD
    main["(main)\n🐧 my-tux"]
    main --> os["(operational-system)\nUbuntu 24.04 Bare Metal"]
    main --> wsl["(wsl)\nUbuntu 24.04 WSL"]
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
