.PHONY: compile install dev-back dev-front

## TypeSpec
install:
	npm --prefix typespec install

compile: install
	npm --prefix typespec run compile

## Backend — заполнить когда будет выбран стек
dev-back:
	@echo "Backend not implemented yet"

## Frontend — заполнить когда будет выбран стек
dev-front:
	@echo "Frontend not implemented yet"
