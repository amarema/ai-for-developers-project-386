# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Context

This is a [Hexlet](https://hexlet.io) educational project repository (ai-for-developers-project-386). Design-First подход: TypeSpec → OpenAPI → frontend + backend.

## Makefile

Все основные команды вызываются через `make`. При добавлении новых частей проекта (backend, frontend) **обязательно добавлять соответствующие цели в `Makefile`** и обновлять этот раздел.

Текущие цели:

- `make install` — установить зависимости TypeSpec
- `make compile` — скомпилировать TypeSpec → `openapi/openapi.yaml`
- `make dev-back` — запустить backend (заглушка, заполнить при добавлении backend)
- `make dev-front` — запустить frontend (заглушка, заполнить при добавлении frontend)

## TypeSpec → OpenAPI

API-контракт описан на TypeSpec. Из него генерируется `openapi/openapi.yaml` — единый источник правды для frontend и backend.

**Структура:**

```
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

## CI

Automated tests are triggered by the `hexlet-check.yml` GitHub Actions workflow on every push. This file must not be deleted, edited, or renamed. Tests require the `HEXLET_ID` secret to be configured in the repository settings.
