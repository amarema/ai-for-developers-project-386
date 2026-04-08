// HTTP-клиент для Calendar Booking API
// Базовый URL берётся из переменной окружения, по умолчанию — localhost:8080 (Prism mock)

import type {
	Booking,
	CreateBookingRequest,
	CreateEventTypeRequest,
	EventType,
	Slot
} from './types.js';

const BASE_URL = import.meta.env.VITE_API_BASE_URL ?? 'http://localhost:8080';

async function request<T>(path: string, init?: RequestInit): Promise<T> {
	const res = await fetch(`${BASE_URL}${path}`, {
		headers: { 'Content-Type': 'application/json', ...init?.headers },
		...init
	});
	if (!res.ok) {
		const error = await res.json().catch(() => ({ message: res.statusText }));
		const err = new Error(error.message ?? res.statusText) as Error & {
			status: number;
			body: unknown;
		};
		err.status = res.status;
		err.body = error;
		throw err;
	}
	return res.json() as Promise<T>;
}

// ── Гостевые эндпоинты ─────────────────────────────────────────────────────

/** GET /event-types — список типов событий для гостя */
export function listEventTypes(): Promise<EventType[]> {
	return request('/event-types');
}

/** GET /event-types/{id}/slots — доступные слоты на 14 дней вперёд */
export function getSlots(id: string): Promise<Slot[]> {
	return request(`/event-types/${encodeURIComponent(id)}/slots`);
}

/** POST /bookings — создать бронирование */
export function createBooking(body: CreateBookingRequest): Promise<Booking> {
	return request('/bookings', { method: 'POST', body: JSON.stringify(body) });
}

// ── Админские эндпоинты ────────────────────────────────────────────────────

/** GET /admin/event-types — список всех типов событий (admin) */
export function adminListEventTypes(): Promise<EventType[]> {
	return request('/admin/event-types');
}

/** POST /admin/event-types — создать тип события */
export function adminCreateEventType(body: CreateEventTypeRequest): Promise<EventType> {
	return request('/admin/event-types', { method: 'POST', body: JSON.stringify(body) });
}

/** GET /admin/bookings — предстоящие бронирования (admin) */
export function adminListBookings(): Promise<Booking[]> {
	return request('/admin/bookings');
}

/** DELETE /admin/bookings/{id} — удалить бронирование */
export async function adminDeleteBooking(id: string): Promise<void> {
	const res = await fetch(`${BASE_URL}/admin/bookings/${encodeURIComponent(id)}`, {
		method: 'DELETE',
		headers: { 'Content-Type': 'application/json' }
	});
	if (!res.ok) {
		const error = await res.json().catch(() => ({ message: res.statusText }));
		throw new Error(error.message ?? res.statusText);
	}
}
