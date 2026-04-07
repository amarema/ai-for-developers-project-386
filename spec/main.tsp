import "@typespec/http";

using TypeSpec.Http;

@service({
  title: "Calendar Booking API",
  version: "1.0.0",
})
@doc("API for a calendar booking application. Supports two roles: calendar owner and guests.")
namespace CalendarBooking;

// ---------------------------------------------------------------------------
// Common error models
// ---------------------------------------------------------------------------

@doc("A generic error response.")
model ErrorResponse {
  @doc("Human-readable error message.")
  message: string;
}

@doc("Conflict error response returned when a slot is already booked.")
model ConflictError {
  @doc("Human-readable description of the conflict.")
  message: string;
}

// ---------------------------------------------------------------------------
// Domain models
// ---------------------------------------------------------------------------

@doc("Represents a type of bookable event offered by the calendar owner.")
model EventType {
  @doc("Unique identifier of the event type.")
  id: string;

  @doc("Short display name of the event type.")
  name: string;

  @doc("Detailed description of the event type.")
  description: string;

  @doc("Duration of the event in minutes.")
  durationMinutes: int32;
}

@doc("Input model for creating a new event type.")
model CreateEventTypeRequest {
  @doc("Short display name of the event type.")
  name: string;

  @doc("Detailed description of the event type.")
  description: string;

  @doc("Duration of the event in minutes.")
  durationMinutes: int32;
}

@doc("Public-facing view of an event type exposed to guests.")
model EventTypePublic {
  @doc("Unique identifier of the event type.")
  id: string;

  @doc("Short display name of the event type.")
  name: string;

  @doc("Detailed description of the event type.")
  description: string;

  @doc("Duration of the event in minutes.")
  durationMinutes: int32;
}

@doc("An available (or unavailable) time slot for a given event type on a specific date.")
model Slot {
  @doc("Start time of the slot in UTC.")
  startTime: utcDateTime;

  @doc("End time of the slot in UTC.")
  endTime: utcDateTime;

  @doc("Whether the slot is still available for booking.")
  available: boolean;
}

@doc("A confirmed booking created by a guest.")
model Booking {
  @doc("Unique identifier of the booking.")
  id: string;

  @doc("Identifier of the event type that was booked.")
  eventTypeId: string;

  @doc("Display name of the event type at the time of booking.")
  eventTypeName: string;

  @doc("Full name of the guest who made the booking.")
  guestName: string;

  @doc("Email address of the guest who made the booking.")
  guestEmail: string;

  @doc("Start time of the booking in UTC.")
  startTime: utcDateTime;

  @doc("End time of the booking in UTC.")
  endTime: utcDateTime;

  @doc("Timestamp when the booking was created, in UTC.")
  createdAt: utcDateTime;
}

@doc("Input model for creating a new booking.")
model CreateBookingRequest {
  @doc("Full name of the guest.")
  guestName: string;

  @doc("Email address of the guest.")
  guestEmail: string;

  @doc("Desired start time for the booking in UTC.")
  startTime: utcDateTime;
}

// ---------------------------------------------------------------------------
// Owner endpoints  —  prefix /owner
// ---------------------------------------------------------------------------

@route("/owner")
@doc("Endpoints available to the calendar owner.")
namespace OwnerApi {
  @route("/event-types")
  @doc("Manage event types.")
  namespace EventTypes {
    @post
    @doc("Create a new event type.")
    op createEventType(
      @body body: CreateEventTypeRequest,
    ): {
      @statusCode statusCode: 201;
      @body eventType: EventType;
    } | {
      @statusCode statusCode: 400;
      @body error: ErrorResponse;
    };

    @get
    @doc("List all event types owned by the calendar owner.")
    op listEventTypes(): {
      @statusCode statusCode: 200;
      @body eventTypes: EventType[];
    };
  }

  @route("/bookings")
  @doc("View all upcoming bookings across every event type.")
  namespace Bookings {
    @get
    @doc("Return all upcoming bookings sorted by startTime in ascending order.")
    op listBookings(): {
      @statusCode statusCode: 200;
      @body bookings: Booking[];
    };
  }
}

// ---------------------------------------------------------------------------
// Guest (public) endpoints  —  prefix /event-types
// ---------------------------------------------------------------------------

@route("/event-types")
@doc("Public endpoints available to guests.")
namespace GuestApi {
  @get
  @doc("List all event types in their public form (name, description, durationMinutes).")
  op listEventTypes(): {
    @statusCode statusCode: 200;
    @body eventTypes: EventTypePublic[];
  };

  @route("/{id}/slots")
  @doc("Retrieve available time slots for a specific event type on a given date.")
  namespace Slots {
    @get
    @doc("Get available slots for the given event type on the specified date.")
    op getSlots(
      @path id: string,
      @doc("Date to query slots for, in YYYY-MM-DD format.")
      @query date: string,
    ): {
      @statusCode statusCode: 200;
      @body slots: Slot[];
    } | {
      @statusCode statusCode: 404;
      @body error: ErrorResponse;
    };
  }

  @route("/{id}/bookings")
  @doc("Create bookings for a specific event type.")
  namespace Bookings {
    @post
    @doc("Create a booking for the chosen slot. Returns 409 Conflict if the slot is already taken.")
    op createBooking(
      @path id: string,
      @body body: CreateBookingRequest,
    ): {
      @statusCode statusCode: 201;
      @body booking: Booking;
    } | {
      @statusCode statusCode: 404;
      @body error: ErrorResponse;
    } | {
      @statusCode statusCode: 409;
      @body error: ConflictError;
    };
  }
}
