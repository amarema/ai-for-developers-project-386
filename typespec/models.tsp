import "@typespec/http";

using TypeSpec.Http;

namespace CalendarBooking;

// ---------------------------------------------------------------------------
// Scalar aliases
// ---------------------------------------------------------------------------

@doc("A slug-style string identifier supplied by the owner (lowercase letters, digits, hyphens).")
scalar Slug extends string;

// ---------------------------------------------------------------------------
// Domain models
// ---------------------------------------------------------------------------

@doc("A type of bookable event defined by the calendar owner.")
model EventType {
  @doc("Owner-supplied slug identifier, e.g. 'intro-call'. Unique across all event types.")
  id: Slug;

  @doc("Short human-readable name displayed to guests.")
  name: string;

  @doc("Full description of what the event covers.")
  description: string;

  @doc("Duration of the event in minutes, e.g. 30 or 60.")
  durationMinutes: int32;
}

@doc("Request body for creating a new event type. The owner supplies the id (slug) explicitly.")
model CreateEventTypeRequest {
  @doc("Owner-chosen slug identifier. Must be unique. Example: 'strategy-session'.")
  id: Slug;

  @doc("Short human-readable name.")
  name: string;

  @doc("Full description of the event.")
  description: string;

  @doc("Duration in minutes.")
  durationMinutes: int32;
}

@doc("A single time slot within the booking window.")
model Slot {
  @doc("Slot start time in UTC.")
  startTime: utcDateTime;

  @doc("Slot end time in UTC, derived from startTime + event durationMinutes.")
  endTime: utcDateTime;

  @doc("True when the slot has no conflicting bookings.")
  available: boolean;
}

@doc("A confirmed booking created by a guest.")
model Booking {
  @doc("System-generated unique booking identifier (UUID).")
  id: string;

  @doc("Identifier of the event type that was booked.")
  eventTypeId: Slug;

  @doc("Display name of the event type captured at booking time.")
  eventTypeName: string;

  @doc("Full name of the guest.")
  guestName: string;

  @doc("Email address of the guest.")
  guestEmail: string;

  @doc("Optional note or comment left by the guest.")
  note?: string;

  @doc("Booking start time in UTC.")
  startTime: utcDateTime;

  @doc("Booking end time in UTC.")
  endTime: utcDateTime;

  @doc("Timestamp when the booking record was created, in UTC.")
  createdAt: utcDateTime;
}

@doc("Request body for creating a booking. The guest selects an event type and a start time.")
model CreateBookingRequest {
  @doc("Identifier of the event type to book.")
  eventTypeId: Slug;

  @doc("Desired start time in UTC. Must correspond to a valid available slot.")
  startTime: utcDateTime;

  @doc("Full name of the guest.")
  guestName: string;

  @doc("Email address of the guest.")
  guestEmail: string;

  @doc("Optional note or comment for the owner.")
  note?: string;
}

// ---------------------------------------------------------------------------
// Error models
// ---------------------------------------------------------------------------

@doc("Generic error response for 400 Bad Request.")
model BadRequestError {
  @doc("Human-readable description of why the request was rejected.")
  message: string;

  @doc("Optional machine-readable error code.")
  code?: string;
}

@doc("Error response for 404 Not Found.")
model NotFoundError {
  @doc("Human-readable description of what was not found.")
  message: string;
}

@doc("Error response for 409 Conflict — returned when a time slot is already booked.")
model ConflictError {
  @doc("Human-readable description of the scheduling conflict.")
  message: string;

  @doc("The conflicting start time in UTC, to help the guest pick another slot.")
  conflictingStartTime?: utcDateTime;
}
