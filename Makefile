#!/usr/bin/env make

# Ensure poetry.lock is up to date before building
build-scratch:
	if [ -d ".dbdata" ]; then sudo chmod -R 755 .dbdata; fi
	docker build --no-cache -t bancho:latest .

build:
	if [ -d ".dbdata" ]; then sudo chmod -R 755 .dbdata; fi
	docker build -t bancho:latest .

# New target to update poetry.lock
update-lock:
	poetry lock --no-update

run:
	docker compose up bancho mysql redis

run-bg:
	docker compose up -d bancho mysql redis

run-caddy:
	caddy run --envfile .env --config ext/Caddyfile

last?=1
logs:
	docker compose logs -f bancho mysql redis --tail ${last}

shell:
	poetry shell

test:
	docker compose -f docker-compose.test.yml up -d bancho-test mysql-test redis-test
	docker compose -f docker-compose.test.yml exec -T bancho-test /srv/root/scripts/run-tests.sh

lint:
	poetry run pre-commit run --all-files

type-check:
	poetry run mypy .

install:
	POETRY_VIRTUALENVS_IN_PROJECT=1 poetry install --no-root

install-dev:
	POETRY_VIRTUALENVS_IN_PROJECT=1 poetry install --no-root --with dev
	poetry run pre-commit install

uninstall:
	poetry env remove python

# To bump the version number run `make bump version=<major/minor/patch>`
bump:
	poetry version $(version)
