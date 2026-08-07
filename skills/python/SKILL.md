---
name: python
description: "Use this skill for any task that may run Python, create or modify `.py` files, install or inspect Python packages, or reason about the Python environment in this container. Trigger for ad-hoc `python`/`python3` commands; data or scientific work; image, mask, raster, or computer-vision comparison and processing; and libraries such as Pillow, OpenCV, scikit-image, xarray, netCDF4, matplotlib, dask, numpy, pandas, scipy, or cartopy. Also trigger before creating any virtual environment or choosing an interpreter. Never create a new venv: use the preconfigured environment directly."
---

# Python environment

This container has a pre-configured Python environment. Use it directly — do not create new venvs, do not use `--user` installs, do not use `--break-system-packages`.

## Required first check

Before the first Python command or package operation, verify the active environment when it has not already been established in the current task:

```bash
which python
echo "$VIRTUAL_ENV"
```

Expect the interpreter at `/home/agent/.venv/bin/python`. Do not create `.venv`, `venv`, `env`, or another environment; use the existing `/home/agent/.venv`. If a repository's instructions request a separate venv, report the conflict and continue with the preconfigured environment unless the user explicitly directs otherwise.

## Running Python

Use the preconfigured interpreter explicitly:

```bash
/home/agent/.venv/bin/python script.py
/home/agent/.venv/bin/python -c "import xarray; print(xarray.__version__)"
```

It is Python 3.12 and is managed by uv. Do not use `/usr/bin/python3`; that is the system interpreter.

## Installing packages

Use `uv pip`, not plain `pip`. It's faster and installs into the active venv automatically:

```bash
uv pip install <package>
uv pip install -r requirements.txt
uv pip uninstall <package>
uv pip list
```

Explicitly target the preconfigured interpreter: `uv pip <command> --python /home/agent/.venv/bin/python ...`. Plain `pip` also works but is slower.

## Pre-installed packages

The following are already installed — no need to install them:

- **Scientific core:** numpy, pandas, scipy
- **NetCDF / climate:** xarray, netCDF4, cftime, h5netcdf, zarr
- **Plotting:** matplotlib, cartopy
- **Parallel:** dask

Check what's available with `uv pip list` before installing anything.

## NetCDF command-line tools

These are also installed system-wide and often faster than Python for simple operations:

- `cdo` — Climate Data Operators (arithmetic, regridding, statistics)
- `ncks`, `ncra`, `ncbo`, etc. — NCO operators
- `ncdump -h file.nc` — inspect file metadata

Prefer these for quick inspection or simple transformations; reach for Python when you need to combine, plot, or do anything non-trivial.

## What NOT to do

- Don't run `python3 -m venv ...` — the venv already exists at `/home/agent/.venv`.
- Don't run `python -m venv`, `virtualenv`, `uv venv`, or environment-creation tools under another spelling.
- Don't create a project-local environment merely to isolate dependencies.
- Don't run `pip install --user` — it installs outside the venv and won't be importable.
- Don't run `sudo pip install` or `pip install --break-system-packages` — bypasses the venv entirely.
- Don't run `uv run --with <package>` for one-offs unless you have a reason — `uv pip install <package>` once and use it normally is simpler for a persistent container.
- Don't run `apt install python3-<something>` — those go to the system Python, which the agent doesn't use.

## Verifying the environment

If anything looks off:

```bash
/home/agent/.venv/bin/python --version         # Python 3.12
uv pip list --python /home/agent/.venv/bin/python
```
