## base

FROM alpine:latest AS agent

ARG UID=1000
ARG GID=1000

ENV UID="${UID}"
ENV GID="${GID}"

ENV USER=agent \
    GROUP=agent \
    HOME=/home/agent

RUN apk add --no-cache --update \
    bash \
    coreutils \
    curl \
    diffutils \
    fd \
    file \
    findutils \
    gawk \
    git \
    github-cli \
    grep \
    gzip \
    jq \
    less \
    make \
    nodejs \
    npm \
    patch \
    procps-ng \
    ripgrep \
    sed \
    tar \
    tree \
    unzip \
    util-linux \
    uv \
    xz \
    yq-go \
    zip

RUN addgroup -g "${GID}" -S "${GROUP}"
RUN adduser -S "${USER}" -u "${UID}" -G "${GROUP}" -h "${HOME}" -s "/bin/sh"

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

RUN uv venv --seed --python 3.14 "$VIRTUAL_ENV"

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
