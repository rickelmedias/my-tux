# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Configuration system via `.env` for full automation.
- `00-nvim-unstable.sh` script to install Neovim v0.12+ (optional).
- Support for multiple Python versions (3.10, 3.11, or both) via `.env`.
- Automatic Git configuration using environment variables.
- Complete documentation: README, CONTRIBUTING, and LICENSE.

### Changed
- `06-pytorch.sh` script now respects `PYTHON_VERSIONS` from `.env`.
- `08-git.sh` script now loads `GIT_USER_NAME` and `GIT_USER_EMAIL` from `.env`.
- Main bootstrap now executes `00-nvim-unstable.sh` if enabled.

### Fixed
- UTF-8 encoding in README (fixed corrupted emojis).
- PyTorch wheels download issue with `%2B` in URL (converted to `+`).

## [1.0.0] - 2026-02-19

### Initial Release

**Tested Hardware:** AMD Ryzen 7 7700X + RX 7800 XT (gfx1101, RDNA3)  
**OS:** Ubuntu 24.04.3 LTS (Noble Numbat)

#### Automatically Installed:
- Essential system packages (build-essential, curl, git, ripgrep, bat, fd, etc.).
- ZSH + Oh My ZSH + Powerlevel10k + plugins (autosuggestions, syntax-highlighting).
- Nerd Fonts (MesloLGS NF).
- Monokai Pro theme for GNOME Terminal.
- Miniconda3 (auto-activate base disabled).
- Docker Engine CE + Compose plugin.
- AMD ROCm 7.2 (package manager, userspace only).
- PyTorch 2.5.1 (Python 3.10) or 2.7.1 (Python 3.11) with ROCm.
- Mise + Java 21, Node LTS, Go, Rust, Maven.
- Git global config + SSH key + git-delta.
- Dotfiles via GNU Stow (zsh, nvim).

#### Features:
- Modular and idempotent scripts.
- State system using a binary bitmask (2 bytes).
- Automatic resume after required reboot (ROCm).
- Detailed logging in `.logs/latest.log`.
- Neovim powered by lazy.nvim + Monokai Pro.
