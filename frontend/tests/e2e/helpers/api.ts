const API = 'http://localhost:8080';

export interface SlotInfo {
	date: string;
	startTime: string;
	endTime: string;
}

export async function getUpcomingSlot(eventTypeId: string): Promise<SlotInfo> {
	const daysRes = await fetch(`${API}/event-types/${eventTypeId}/available-days`);
	const days: string[] = await daysRes.json();
	if (!days.length) throw new Error(`Нет доступных дней для ${eventTypeId}`);

	const slotsRes = await fetch(`${API}/event-types/${eventTypeId}/slots?date=${days[0]}`);
	const slots: Array<{ startTime: string; endTime: string }> = await slotsRes.json();
	if (!slots.length) throw new Error(`Нет слотов на первый доступный день для ${eventTypeId}`);

	return { date: days[0], startTime: slots[0].startTime, endTime: slots[0].endTime };
}

export async function createBookingViaApi(params: {
	eventTypeId: string;
	startTime: string;
	guestName: string;
	guestEmail: string;
	note?: string;
}): Promise<{ id: string }> {
	const res = await fetch(`${API}/bookings`, {
		method: 'POST',
		headers: { 'Content-Type': 'application/json' },
		body: JSON.stringify(params),
	});
	if (!res.ok) {
		const body = await res.json().catch(() => ({}));
		throw new Error(`Ошибка создания брони: ${res.status} ${body.message ?? ''}`);
	}
	return res.json();
}

export async function deleteBookingViaApi(id: string): Promise<void> {
	await fetch(`${API}/admin/bookings/${id}`, { method: 'DELETE' });
}
