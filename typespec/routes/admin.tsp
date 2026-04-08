import "@typespec/http";
import "@typespec/rest";

using TypeSpec.Http;
using TypeSpec.Rest;

namespace CalendarBooking;

@doc("Эндпоинты для владельца календаря. Авторизация не требуется (единственный предопределённый владелец).")
@route("/admin")
interface AdminApi {
  @doc("""
    Создать новый тип события.
    Владелец указывает id (slug) в теле запроса.
    Возвращает 400, если id уже занят или входные данные некорректны.
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

  @doc("Получить список всех типов событий, созданных владельцем.")
  @get
  @route("/event-types")
  listEventTypes(): {
    @statusCode statusCode: 200;
    @body eventTypes: EventType[];
  };

  @doc("""
    Получить список предстоящих бронирований по всем типам событий, отсортированных по startTime по возрастанию.
    Предстоящие — те, у которых startTime не раньше текущего времени сервера.
  """)
  @get
  @route("/bookings")
  listBookings(): {
    @statusCode statusCode: 200;
    @body bookings: Booking[];
  };

  @doc("Удалить бронирование по id. Возвращает 404, если бронирование не найдено.")
  @delete
  @route("/bookings/{id}")
  deleteBooking(
    @path id: string,
  ): {
    @statusCode statusCode: 204;
  } | {
    @statusCode statusCode: 404;
    @body error: NotFoundError;
  };
}
