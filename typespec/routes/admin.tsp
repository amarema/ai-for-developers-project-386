import "@typespec/http";
import "@typespec/rest";

using TypeSpec.Http;
using TypeSpec.Rest;

namespace CalendarBooking;

@doc("Admin endpoints accessible only by the calendar owner. No authentication required (single predefined owner).")
@route("/admin")
interface AdminApi {
  @doc("""
    Create a new event type.
    The owner supplies the id (slug) in the request body.
    Returns 400 if the id is already taken or input is invalid.
  """)
  @post
  @route("/event-types")
  createEventType(
    @body body: CreateEventTypeRequest,
  ): {
    @statusCode statusCode: 201;
    @body eventType: EventType;
  } | {
    @statusCode statusCode: 400;
    @body error: BadRequestError;
  };

  @doc("List all event types created by the owner.")
  @get
  @route("/event-types")
  listEventTypes(): {
    @statusCode statusCode: 200;
    @body eventTypes: EventType[];
  };

  @doc("""
    List all upcoming bookings across all event types, sorted by startTime ascending.
    Upcoming means startTime is at or after the current server time.
  """)
  @get
  @route("/bookings")
  listBookings(): {
    @statusCode statusCode: 200;
    @body bookings: Booking[];
  };
}
