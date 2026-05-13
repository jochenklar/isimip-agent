---
name: uv
description: Use the uv tool for all Python operations in this project. Applies whenever running Python, installing packages, managing virtualenvs, or executing Python scripts/tools. The Docker image (`FROM node:22-trixie-slim` with `COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/`) provides `uv` and `uvx` but no system `python` or `pip`.
---

# Use uv for Python

This project's runtime image is:

```dockerfile
FROM node:22-trixie-slim
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/
```

There is **no** system `python`, `python3`, `pip`, `pipx`, `venv`, or `virtualenv`. Only `uv` and `uvx` are available. Always use them.

## Substitutions

Whenever you would otherwise reach for a Python tool, use the uv equivalent instead:

| Don't use            | Use instead                          |
|----------------------|--------------------------------------|
| `python script.py`   | `uv run script.py`                   |
| `python -m module`   | `uv run -m module`                   |
| `pip install X`      | `uv pip install X` (in a uv venv) or `uv add X` (in a uv project) |
| `pip install -r requirements.txt` | `uv pip install -r requirements.txt` |
| `python -m venv .venv` | `uv venv`                          |
| `pipx run tool`      | `uvx tool`                           |
| `pipx install tool`  | `uv tool install tool`               |

## Running scripts

- One-off script: `uv run script.py`
- Script with inline deps (PEP 723): add a `# /// script` block and run `uv run script.py`
- Ephemeral CLI tool: `uvx ruff check .`, `uvx black .`, `uvx pytest`

## Projects

- Init: `uv init`
- Add deps: `uv add requests`
- Add dev deps: `uv add --dev pytest`
- Sync: `uv sync`
- Run in project env: `uv run pytest`

## Dockerfiles and CI

When editing Dockerfiles or CI for this project, do not add `apt-get install python3` or pip-based setup. Use `uv` directly; install Python versions with `uv python install <version>` if needed.
