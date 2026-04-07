.PHONY: compile install dev-back dev-front

## TypeSpec
install:
	npm install

compile: install
	npm run compile

## Backend — заполнить когда будет выбран стек
dev-back:
	@echo "Backend not implemented yet"

## Frontend — заполнить когда будет выбран стек
dev-front:
	@echo "Frontend not implemented yet"
