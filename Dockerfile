## isimip-agent-base

FROM debian:trixie-slim AS isimip-agent
COPY --from=ghcr.io/astral-sh/uv /uv /uvx /bin/

ARG UID=1000
ARG GID=1000

ENV UID="${UID}"
ENV GID="${GID}"

ENV USER=agent
ENV GROUP=agent
ENV HOME=/home/agent

RUN apt-get update && apt-get install -y --no-install-recommends \
        build-essential \
        ca-certificates \
        cdo \
        curl \
        fd-find \
        git \
        gnupg \
        jq \
        nco \
        netcdf-bin \
        ripgrep \
    && ln -s $(which fdfind) /usr/local/bin/fd \
    && rm -rf /var/lib/apt/lists/*

RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - \
    && apt-get install -y nodejs

# Run as a non-root user.
RUN groupadd -g "${GID}" -r "${USER}"
RUN useradd -r -u "${UID}" -g "${GROUP}" -m -d "${HOME}" -s /bin/bash "${USER}"

RUN mkdir -p /datasets /workspace
RUN chown "${USER}":"${GROUP}" /datasets /workspace

USER "${USER}"
WORKDIR /workspace

ENV VIRTUAL_ENV="${HOME}/.venv" \
    UV_PYTHON_INSTALL_DIR="${HOME}/.python" \
    UV_LINK_MODE=copy \
    PATH="${HOME}/.npm-global/bin:${HOME}/.venv/bin/:${PATH}"

RUN uv venv --python 3.12 "$VIRTUAL_ENV" \
    && uv pip install --no-cache \
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

## isimip-pi

FROM isimip-agent AS isimip-pi

RUN npm config set prefix "${HOME}/.npm-global" \
    && npm install -g @earendil-works/pi-coding-agent \
    && npm cache clean --force
RUN mkdir -p /home/agent/.pi/agent

CMD ["pi"]

## isimip-claude

FROM isimip-agent AS isimip-claude

RUN npm config set prefix "${HOME}/.npm-global" \
    && npm install -g @anthropic-ai/claude-code \
    && npm cache clean --force

CMD ["claude", "--dangerously-skip-permissions"]

## isimip-codex

FROM isimip-agent AS isimip-codex

RUN npm config set prefix "${HOME}/.npm-global" \
    && npm install -g @openai/codex \
    && npm cache clean --force
RUN mkdir -p /home/agent/.codex /home/agent/.agents/skills/

CMD ["codex", "--yolo"]

## isimip-tau

FROM isimip-agent AS isimip-tau

RUN uv pip install --no-cache tau-ai
RUN mkdir -p /home/agent/.tau

CMD ["tau"]
