## isimip-agent base

FROM debian:trixie-slim AS agent
COPY --from=ghcr.io/astral-sh/uv /uv /uvx /bin/

ARG UID=1000
ARG GID=1000

ENV UID="${UID}"
ENV GID="${GID}"

ENV USER=agent \
    GROUP=agent \
    HOME=/home/agent

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
        unzip \
    && ln -s $(which fdfind) /usr/local/bin/fd \
    && rm -rf /var/lib/apt/lists/*

RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - \
    && apt-get install -y nodejs

RUN groupadd --system --gid "${GID}" "${GROUP}"
RUN useradd -r -u "${UID}" -g "${GROUP}" -m -d "${HOME}" -s /bin/bash "${USER}"

RUN mkdir -p /home/agent/workspace /opt/env /opt/npm /opt/python
RUN chown -R "${UID}:${GID}" "${HOME}" /home/agent/workspace /opt/env /opt/npm /opt/python

USER "${USER}"
WORKDIR /home/agent/workspace

ENV VIRTUAL_ENV="/opt/env" \
    UV_PROJECT_ENVIRONMENT="/opt/env" \
    UV_PYTHON_INSTALL_DIR="/opt/python" \
    UV_LINK_MODE=copy \
    PATH="/opt/npm/bin:/opt/env/bin:${PATH}"

RUN npm config set prefix "/opt/npm"

RUN uv venv --seed --python 3.12 "$VIRTUAL_ENV" \
    && uv pip install --no-cache \
        cartopy \
        cftime \
        dask \
        h5netcdf \
        isimip-ea \
        isimip-qc \
        isimip-utils \
        matplotlib \
        netCDF4 \
        numpy \
        pandas \
        scipy \
        xarray \
        zarr

## pi

FROM agent AS pi

RUN npm install -g @earendil-works/pi-coding-agent
RUN mkdir -p /home/agent/.pi/agent

CMD ["pi"]

## opencode

FROM agent AS opencode

RUN npm install -g opencode-ai@latest
RUN mkdir -p /home/agent/.config/opencode

CMD ["opencode", "--auto"]

## claude

FROM agent AS claude

RUN npm install -g @anthropic-ai/claude-code
RUN mkdir -p /home/agent/.claude/skills

CMD ["claude", "--dangerously-skip-permissions"]

## codex

FROM agent AS codex

RUN npm install -g @openai/codex
RUN mkdir -p /home/agent/.codex /home/agent/.codex/skills/

CMD ["codex", "--yolo"]

## tau

FROM agent AS tau

RUN uv pip install --no-cache tau-ai
RUN mkdir -p /home/agent/.tau

CMD ["tau"]
