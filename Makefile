# include the vars from the .env file
-include .env

# set default variables for env
AGENT ?= pi
WORKSPACE_PATH ?= ./workspace

# set compose env vars
COMPOSE_PROFILES := $(AGENT)
COMPOSE_FILE := compose.yaml$(if $(wildcard $(AGENT).yaml),:$(AGENT).yaml)

ifeq ($(shell uname -s),Darwin)
# macOS
AGENT_UID := 1000
AGENT_GID := 1000
else ifeq ($(shell id -u),0)
# root
AGENT_UID := 1000
AGENT_GID := 1000
else
# regular user
AGENT_UID := $(shell id -u)
AGENT_GID := $(shell id -g)
endif

export AGENT_UID AGENT_GID COMPOSE_PROFILES COMPOSE_FILE

.PHONY: run bash build mlx setup clean

run: setup
	docker compose run --rm $(AGENT)

bash: setup
	docker compose run --rm $(AGENT) bash

build:
	docker compose build

mlx:
	mlx_lm.server --port 4040

setup:
	mkdir -p $(WORKSPACE_PATH)
ifeq ($(shell id -u),0)
	chown $(AGENT_UID):$(AGENT_GID) $(WORKSPACE_PATH)
endif

clean:
	-docker compose rm -sfv $(AGENT)
	-docker volume rm "$$(docker compose config | sed -n 's/^name: //p')_$(AGENT)"
