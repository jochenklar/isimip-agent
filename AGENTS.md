# Rules

Rules in this file are loaded by the agent in every session.

## Git and GitHub

- Never stage, commit, push, or otherwise change the git history (no `git add`,
  `git commit`, `git push`, `git rebase`, `git reset`, `git stash`, ...). Leave
  all changes in the working tree for the user to review and commit.
- Never create or edit pull requests, issues, comments, or reviews on GitHub,
  neither with `gh` nor through the API.
- Read-only use is fine, e.g. `git status`, `git diff`, `git log`, `gh pr view`
  or `gh issue list`.
- If the user asks for one of these actions, explain that it is not allowed in
  this setup and give them the command to run themselves.

## Tests

- Never run `pytest` or `playwright`, in any form (e.g. `uv run pytest`,
  `python -m pytest`, `npx playwright test`, `playwright install`), and do not
  install them.
- Writing or changing tests is fine. Instead of running them, tell the user
  which command to run.

## Environment

You run inside a Docker container, which is your sandbox:

- The OS is Alpine Linux (musl, not glibc). Some prebuilt binaries or Python
  wheels for glibc may not work.
- You run as the unprivileged user `agent` (home `/home/agent`). There is no
  root access and no `sudo`, so `apk add` is not possible. If system packages
  are missing, tell the user they need to be added to the `Dockerfile`.
- Your working directory is `/home/agent/workspace`. It is mounted from the
  host, and changes there are what the user sees.
- `/home/agent` is a persistent volume. Everything else (e.g. `/opt`, `/tmp`)
  is reset when the container restarts.
- Available tools: `bash`, `git`, `gh`, `curl`, `jq`, `yq`, `rg`, `fd`, `make`,
  `tree`, `file`, archive tools (`tar`, `gzip`, `xz`, `zip`, `unzip`) and the
  GNU versions of coreutils, `findutils`, `sed`, `grep`, `awk`, `diff`,
  `patch` and `ps`.
- Python 3.14 is available through `uv` in the virtualenv `/opt/env`, which is
  already on the `PATH`. Use `uv pip install` or `uv run`. Packages installed
  into `/opt/env` are lost on restart, so prefer project-local environments or
  declaring dependencies in the project.
- Node.js and `npm` are available. Global npm packages go to `/opt/npm` and are
  also lost on restart.
- There is no SSH client. Use HTTPS for git remotes.
- Services on the host (e.g. Ollama on port 11434 or an MLX server on port
  4040) are reachable at `host.docker.internal`.
