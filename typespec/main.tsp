import "@typespec/http";
import "@typespec/rest";
import "@typespec/openapi3";

import "./models.tsp";
import "./routes/admin.tsp";
import "./routes/guest.tsp";

using TypeSpec.Http;
using TypeSpec.Rest;

@service({
  title: "Calendar Booking API",
})
@doc("REST API for a calendar booking application. Supports two roles: the calendar owner (admin) and anonymous guests.")
@server("http://localhost:8080", "Local development server")
namespace CalendarBooking;
