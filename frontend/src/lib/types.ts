// Типы, сгенерированные из openapi/openapi.yaml

export type Slug = string;

export interface EventType {
	id: Slug;
	name: string;
	description: string;
	durationMinutes: number;
}

export interface Slot {
	startTime: string; // ISO 8601 / UTC
	endTime: string;
}

export interface Booking {
	id: string;
	eventTypeId: Slug;
	eventTypeName: string;
	guestName: string;
	guestEmail: string;
	note?: string;
	startTime: string;
	endTime: string;
	createdAt: string;
}

export interface CreateEventTypeRequest {
	id: Slug;
	name: string;
	description: string;
	durationMinutes: number;
}

export interface CreateBookingRequest {
	eventTypeId: Slug;
	startTime: string;
	guestName: string;
	guestEmail: string;
	note?: string;
}

export interface BadRequestError {
	message: string;
	code?: string;
}

export interface NotFoundError {
	message: string;
}

export interface ConflictError {
	message: string;
	conflictingStartTime?: string;
}
