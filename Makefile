.PHONY: reproduce

SUDO ?= sudo

PG_NAME ?= db-repro
PG_USER ?= repro
PG_PASS ?= repro
PG_DB   ?= repro_backend
PG_HOST ?= localhost
PG_PORT ?= 5437
DATABASE_URL = postgres://$(PG_USER):$(PG_PASS)@$(PG_HOST):$(PG_PORT)/$(PG_DB)

reproduce:
	cargo install diesel_cli@2.0.1 --no-default-features --features "postgres"
	docker kill $(PG_NAME) || true
	$(SUDO) mkdir -p pgdata
	$(SUDO) rm -rf pgdata/*
	docker run --rm --detach \
		--name $(PG_NAME) \
		--env POSTGRES_USER=$(PG_USER) \
		--env POSTGRES_PASSWORD=$(PG_PASS) \
		--env POSTGRES_DB=$(PG_DB) \
		--env PGDATA=/var/lib/postgresql/data/pgdata \
		--env PGPORT=$(PG_PORT) \
		--volume "$(PWD)"/pgdata/$(PG_NAME):/var/lib/postgresql/data \
		--publish 127.0.0.1:$(PG_PORT):$(PG_PORT) \
		postgres:14-alpine
	sleep 1
	DATABASE_URL=$(DATABASE_URL) diesel migration run
