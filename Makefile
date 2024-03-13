DB_CONTAINER_NAME=vehicle-server-dev
POSTGRES_USER=vehicle-server
POSTGRES_PASSWORD=secret
POSTGRES_DB=vehicle-server
DATABASE_URL=postgres://$(POSTGRES_USER):$(POSTGRES_PASSWORD)@localhost:5432/$(POSTGRES_DB)
IMAGE?=outmrhoust/vehicle-server
TAG?=1.0.0
.PHONY: dev
dev:
	go run ./cmd/server \
		-listen-address=:8080 \
		-database-url=$(DATABASE_URL)

.PHONY: dev_db
dev_db:
	docker container run \
		--detach \
		--rm \
		--name=$(DB_CONTAINER_NAME) \
		--env=POSTGRES_PASSWORD=$(POSTGRES_PASSWORD) \
		--env=POSTGRES_USER=$(POSTGRES_USER) \
		--env=POSTGRES_DB=$(POSTGRES_DB) \
		--publish 5432:5432 \
		postgis/postgis:16-3.4-alpine

.PHONY: stop_dev_db
stop_dev_db:
	docker container stop $(DB_CONTAINER_NAME)

.PHONY: all
all: clean dist build unit_test integration_test package

.PHONY: clean
clean:
	rm -rf ./dist
.PHONY: dist
dist:
	mkdir dist
.PHONY: build
build:
	go build -o ./dist ./cmd/server/main.go

.PHONY: unit_test
unit_test:
	go test -v -cover ./...

.PHONY: integration_test
integration_test:
	go test -v -count=1 --tags=integration ./app
.PHONY: package
package:
	docker image build -t $(IMAGE):$(TAG) ./
.PHONY: release
	git tag 1.0.0 -a -m "Release ${TAG}"
	git push origin ${TAG}
	docker push $(IMAGE):$(TAG)