# Contributing to my-tux

Thank you for your interest in contributing! This project is community-driven and welcomes contributions of all kinds.

## How you can help

### Reporting bugs
- Open an [Issue](https://github.com/your-username/my-tux/issues/new).
- Describe the problem with as much detail as possible.
- Include relevant logs (`.logs/latest.log`).
- Provide your Ubuntu version, kernel, and GPU model.

### Suggesting improvements
- Open an [Issue](https://github.com/your-username/my-tux/issues/new) with the `enhancement` tag.
- Explain the use case and describe the proposed solution.

### Improving documentation
- Fix typos or grammatical errors.
- Add examples or improve the clarity of instructions.

### Adding support for new hardware
- Tested on a different AMD GPU? Please share!
- Using a different Linux distribution? Fork and adapt it!

## Submitting Pull Requests

1. **Fork** the repository.
2. **Clone** your fork: `git clone https://github.com/your-username/my-tux.git`.
3. **Create a branch** for your feature: `git checkout -b feat/my-feature`.
4. **Make your changes** and **Test** locally.
5. **Commit** with clear messages (e.g., `feat: add support for RX 7900 XTX`).
6. **Push** to your fork and **Open a Pull Request**.

## Coding Conventions

- **Bash**: Use `set -euo pipefail` in all scripts.
- **Indentation**: 2 spaces.
- **Comments**: Preferably in English for global reach.
- **Naming**: 
  - Scripts: `XX-descriptive-name.sh` (where XX is the order).
  - Functions: `snake_case`.
  - Variables: `UPPER_CASE` for globals, `lower_case` for locals.

## Testing Locally

```bash
# Test in a VM or container first!
# NEVER test in production
```

## License

By contributing, you agree that your contributions will be licensed under the same MIT License as the project.
