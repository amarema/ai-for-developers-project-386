import "@typespec/http";
import "@typespec/rest";

using TypeSpec.Http;
using TypeSpec.Rest;

namespace CalendarBooking;

@doc("Публичные эндпоинты для анонимных гостей. Авторизация не требуется.")
interface GuestApi {
  @doc("Получить список всех типов событий в публичном виде: id, name, description, durationMinutes.")
  @get
  @route("/event-types")
  listEventTypes(): {
    @statusCode statusCode: 200;
    @body eventTypes: EventType[];
  };

  @doc("""
    Получить все временные слоты для указанного типа события в ближайшие 14 календарных дней.
    Слоты генерируются по будням с понедельника по пятницу, в диапазоне 09:00–18:00 (локальное время сервера).
    Длина слота равна durationMinutes типа события.
    Слоты, перекрытые существующим бронированием (любого типа события), отмечаются как available: false.
    Возвращает 404, если тип события с указанным id не существует.
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
    Создать бронирование на выбранный слот.
    Проверяемые бизнес-правила:
    - Слот должен приходиться на будний день (Пн–Пт) в диапазоне 09:00–18:00.
    - Слот должен попадать в окно бронирования — 14 дней от сегодня.
    - Ни одно другое бронирование (любого типа события) не должно перекрывать запрошенный диапазон.
    Возвращает 400 при некорректных входных данных, 404 если тип события не найден,
    и 409 Conflict если слот уже занят.
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
