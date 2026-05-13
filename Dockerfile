FROM node:22-trixie-slim
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/

RUN apt-get update && apt-get install -y --no-install-recommends \
        build-essential \
        ca-certificates \
        cdo \
        curl \
        fd-find \
        git \
        jq \
        libnetcdf-dev \
        nco \
        ncview \
        netcdf-bin \
        netcdf-bin \
        ripgrep \
    && rm -rf /var/lib/apt/lists/*

RUN ln -s $(which fdfind) /usr/local/bin/fd

# Run as a non-root user.
RUN useradd -m -s /bin/bash pi
USER pi
WORKDIR /home/pi

# Install Pi globally for the pi user.
RUN npm config set prefix '/home/pi/.npm-global' \
    && npm install -g @earendil-works/pi-coding-agent
ENV PATH="/home/pi/.npm-global/bin:${PATH}"

# Python venv owned by pi
ENV VIRTUAL_ENV=/home/pi/.venv
ENV UV_CACHE_DIR=/home/pi/.cache/uv
ENV PATH="/home/pi/.npm-global/bin:/home/pi/.venv/bin:${PATH}"

RUN uv venv --python 3.12 "$VIRTUAL_ENV" \
    && uv pip install \
        cartopy \
        cftime \
        dask \
        h5netcdf \
        matplotlib \
        netCDF4 \
        numpy \
        pandas \
        scipy \
        xarray \
        zarr

# Pre-create the config dir as the pi user. When the named volume mounts
# at /home/pi/.pi, Docker initializes a fresh volume by copying this
# directory's contents AND ownership — without this, the volume is
# owned by root and Pi can't write its session files.
RUN mkdir -p /home/pi/.pi

# Working directory you'll mount your project into.
WORKDIR /workspace

CMD ["pi"]
