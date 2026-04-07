import "@typespec/http";
import "@typespec/rest";

using TypeSpec.Http;
using TypeSpec.Rest;

namespace CalendarBooking;

@doc("Public endpoints available to anonymous guests. No authentication required.")
interface GuestApi {
  @doc("List all event types in their public form: id, name, description, durationMinutes.")
  @get
  @route("/event-types")
  listEventTypes(): {
    @statusCode statusCode: 200;
    @body eventTypes: EventType[];
  };

  @doc("""
    Get all time slots for a specific event type within the next 14 calendar days.
    Slots are generated for weekdays Monday–Friday, between 09:00 and 18:00 (server local time).
    Slot length equals the event type's durationMinutes.
    Slots already covered by an existing booking (any event type) are marked available: false.
    Returns 404 if the event type id does not exist.
  """)
  @get
  @route("/event-types/{id}/slots")
  getSlots(
    @path id: Slug,
  ): {
    @statusCode statusCode: 200;
    @body slots: Slot[];
  } | {
    @statusCode statusCode: 404;
    @body error: NotFoundError;
  };

  @doc("""
    Create a booking on the chosen slot.
    Business rules enforced:
    - The slot must fall on a weekday (Mon–Fri) between 09:00 and 18:00.
    - The slot must be within the 14-day booking window from today.
    - No other booking (any event type) may overlap the requested time range.
    Returns 400 for invalid input, 404 if the event type does not exist,
    and 409 Conflict if the slot is already taken.
  """)
  @post
  @route("/bookings")
  createBooking(
    @body body: CreateBookingRequest,
  ): {
    @statusCode statusCode: 201;
    @body booking: Booking;
  } | {
    @statusCode statusCode: 400;
    @body error: BadRequestError;
  } | {
    @statusCode statusCode: 404;
    @body error: NotFoundError;
  } | {
    @statusCode statusCode: 409;
    @body error: ConflictError;
  };
}
