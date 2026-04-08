# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Соглашения

Комментарии в коде (TypeSpec, frontend, backend) пишутся на русском языке.

При возникновении неясностей или неоднозначностей агент должен задавать уточняющие вопросы пользователю, а не принимать решения самостоятельно.

## Makefile

Все основные команды вызываются через `make`. При добавлении новых частей проекта (backend, frontend) **обязательно добавлять соответствующие цели в `Makefile`** и обновлять этот раздел.

Текущие цели:

- `make install` — установить зависимости TypeSpec
- `make compile` — скомпилировать TypeSpec → `openapi/openapi.yaml`
- `make install-front` — установить зависимости frontend
- `make dev-front` — запустить frontend (SvelteKit, порт 5173)
- `make mock-api` — запустить Prism mock-сервер (порт 8080, на базе openapi/openapi.yaml)
- `make install-back` — установить зависимости backend (Go modules)
- `make generate-back` — сгенерировать server-код из `openapi/openapi.yaml` через oapi-codegen
- `make dev-back` — запустить backend (Go/Gin, порт 8080)
- `make dev` — запустить backend и frontend одновременно

## TypeSpec → OpenAPI

API-контракт описан на TypeSpec. Из него генерируется `openapi/openapi.yaml` — единый источник правды для frontend и backend.

**Структура:**

```text
typespec/
  main.tsp          # точка входа, декларация сервиса
  models.tsp        # доменные модели и error-модели
  routes/
    admin.tsp       # AdminApi: POST/GET /admin/event-types, GET /admin/bookings
    guest.tsp       # GuestApi: GET /event-types, GET /event-types/{id}/slots, POST /bookings
```

**Бизнес-правила, зафиксированные в контракте:**

- Нельзя создать два бронирования на одно и то же время (любой тип события) → 409 Conflict
- Доступные слоты: Пн–Пт, 09:00–18:00, окно 14 дней от сегодня
- `id` типа события задаёт владелец (slug-формат), хранится в `Slug` scalar
- Гость указывает имя, email и опциональную заметку при бронировании

## Backend (Go/Gin)

**Стек:** Go + Gin + oapi-codegen

**Директория:** `backend/`

**Архитектура:** handler → service → store (in-memory, thread-safe через RWMutex)

**Структура:**

```text
backend/
  main.go               # Gin setup, CORS (localhost:5173), маршрутизация
  oapi-codegen.yaml     # конфигурация кодогенерации
  gen/server.gen.go     # сгенерированный интерфейс сервера и типы из OpenAPI
  internal/handler/     # реализация всех 6 эндпоинтов
  internal/service/     # бизнес-логика (генерация слотов, валидация бронирований)
  internal/store/       # in-memory хранилища EventType и Booking
```

**Цепочка кодогенерации:** TypeSpec → `openapi/openapi.yaml` → `gen/server.gen.go`

При изменении TypeSpec нужно выполнить `make compile && make generate-back`.

## Frontend (SvelteKit)

**Стек:** SvelteKit + Vite + shadcn-svelte (vega preset) + Tailwind CSS v4

**Директория:** `frontend/`

**Маршруты:**
- `/` — список типов событий (гость)
- `/event-types/[id]` — выбор слота + форма бронирования (гость)
- `/booking/success` — подтверждение бронирования
- `/admin/event-types` — управление типами событий (admin)
- `/admin/bookings` — предстоящие бронирования (admin)

**Ключевые файлы:**
- `frontend/src/lib/api.ts` — типизированный HTTP-клиент для всех 6 эндпоинтов
- `frontend/src/lib/types.ts` — TypeScript-типы из OpenAPI-контракта
- `frontend/src/app.css` — глобальные стили + CSS-переменные shadcn-svelte + @theme для Tailwind v4
- `frontend/components.json` — конфигурация shadcn-svelte CLI (preset: vega)
- `frontend/.env` — `VITE_API_BASE_URL=http://localhost:8080`

**Запуск (два терминала):**
```
make mock-api   # терминал 1: Prism mock на :8080
make dev-front  # терминал 2: SvelteKit на :5173
```