.PHONY: compile install install-front install-back generate-back dev-back dev-front mock-api dev docker-build docker-run

## TypeSpec
install:
	npm --prefix typespec install

compile: install
	npm --prefix typespec run compile

## Frontend
install-front:
	npm --prefix frontend install

dev-front:
	npm --prefix frontend run dev

## Mock API (Stoplight Prism) — эмулятор backend на базе openapi/openapi.yaml
mock-api:
	npx @stoplight/prism-cli mock openapi/openapi.yaml --port 8080

## Запустить backend и frontend одновременно
dev:
	make -j2 dev-back dev-front

## Backend — Go + Gin (порт 8080)
install-back:
	cd backend && go mod download

generate-back:
	cd backend && ~/go/bin/oapi-codegen -config oapi-codegen.yaml ../openapi/openapi.yaml

dev-back:
	cd backend && go run ./main.go

## Docker
docker-build:
	docker build -t calendar-booking .

docker-run:
	docker run -p 8080:8080 -e PORT=8080 calendar-booking

## E2E-тесты (Playwright + Chromium)
install-e2e: install-front
	npm --prefix frontend exec playwright install --with-deps chromium

test-e2e:
	npm --prefix frontend run test:e2e

test-e2e-ui:
	npm --prefix frontend run test:e2e:ui
