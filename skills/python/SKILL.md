---
name: python
description: Use this skill whenever the agent needs to run Python, install Python packages, or understand the Python setup in this container. Triggers include running `.py` files, installing packages with pip/uv, creating scripts, working with xarray/netCDF4/matplotlib/dask/numpy/pandas/scipy/cartopy, or any task involving NetCDF data analysis in Python. Do NOT create new venvs or use `python3 -m venv` — the environment is already set up.
---

# Python environment

This container has a pre-configured Python environment. Use it directly — do not create new venvs, do not use `--user` installs, do not use `--break-system-packages`.

## Running Python

Just call `python` or `python3`:

```bash
python script.py
python -c "import xarray; print(xarray.__version__)"
```

`python` resolves to `/home/pi/.venv/bin/python` (Python 3.12, managed by uv). Both `python` and `python3` work.

## Installing packages

Use `uv pip`, not plain `pip`. It's faster and installs into the active venv automatically:

```bash
uv pip install <package>
uv pip install -r requirements.txt
uv pip uninstall <package>
uv pip list
```

`VIRTUAL_ENV` is already exported, so `uv pip` targets `/home/pi/.venv` without any flags. Plain `pip` also works but is slower.

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
- `ncview file.nc` — GUI viewer (needs X display)

Prefer these for quick inspection or simple transformations; reach for Python when you need to combine, plot, or do anything non-trivial.

## What NOT to do

- Don't run `python3 -m venv ...` — the venv already exists at `/home/pi/.venv`.
- Don't run `pip install --user` — it installs outside the venv and won't be importable.
- Don't run `sudo pip install` or `pip install --break-system-packages` — bypasses the venv entirely.
- Don't run `uv run --with X` for one-offs unless you have a reason — `uv pip install X` once and use it normally is simpler for a persistent container.
- Don't run `apt install python3-<something>` — those go to the system Python, which the agent doesn't use.

## Verifying the environment

If anything looks off:

```bash
which python          # should be /home/pi/.venv/bin/python
echo $VIRTUAL_ENV     # should be /home/pi/.venv
python --version      # Python 3.12.x
uv pip list           # lists packages in the venv
```
