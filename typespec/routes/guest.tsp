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
    Получить список дат (формат YYYY-MM-DD) на ближайшие 14 дней, в которые есть хотя бы один свободный слот.
    Используется для первичной отрисовки календаря. Возвращает 404, если тип события не найден.
  """)
  @get
  @route("/event-types/{id}/available-days")
  getAvailableDays(
    @path id: Slug,
  ): {
    @statusCode statusCode: 200;
    @body dates: string[];
  } | {
    @statusCode statusCode: 404;
    @body error: NotFoundError;
  };

  @doc("""
    Получить свободные слоты для указанного типа события на конкретную дату (YYYY-MM-DD).
    Слоты генерируются по будням с 09:00 до 18:00 (локальное время сервера).
    Возвращаются только слоты без конфликтующих бронирований.
    Возвращает 404, если тип события не найден.
  """)
  @get
  @route("/event-types/{id}/slots")
  getSlots(
    @path id: Slug,
    @doc("Дата в формате YYYY-MM-DD.")
    @query date: string,
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
