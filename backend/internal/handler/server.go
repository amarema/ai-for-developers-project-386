package handler

import (
	"net/http"
	"time"

	"github.com/gin-gonic/gin"

	"calendar-booking/gen"
	"calendar-booking/internal/service"
	"calendar-booking/internal/store"
)

// Server реализует gen.ServerInterface
type Server struct {
	etStore *store.EventTypeStore
	bStore  *store.BookingStore
}

func NewServer(etStore *store.EventTypeStore, bStore *store.BookingStore) *Server {
	return &Server{etStore: etStore, bStore: bStore}
}

// --- Guest API ---

// GuestApiListEventTypes возвращает список всех типов событий
func (s *Server) GuestApiListEventTypes(c *gin.Context) {
	c.JSON(http.StatusOK, s.etStore.FindAll())
}

// GuestApiGetAvailableDays возвращает даты с хотя бы одним свободным слотом
func (s *Server) GuestApiGetAvailableDays(c *gin.Context, id gen.Slug) {
	et, ok := s.etStore.FindByID(string(id))
	if !ok {
		c.JSON(http.StatusNotFound, gen.NotFoundError{Message: "тип события не найден: " + string(id)})
		return
	}

	dates := service.GenerateAvailableDays(et, s.bStore)
	c.JSON(http.StatusOK, dates)
}

// GuestApiGetSlots возвращает свободные слоты для типа события на конкретную дату
func (s *Server) GuestApiGetSlots(c *gin.Context, id gen.Slug, params gen.GuestApiGetSlotsParams) {
	et, ok := s.etStore.FindByID(string(id))
	if !ok {
		c.JSON(http.StatusNotFound, gen.NotFoundError{Message: "тип события не найден: " + string(id)})
		return
	}

	date, err := time.ParseInLocation("2006-01-02", params.Date, time.Local)
	if err != nil {
		c.JSON(http.StatusBadRequest, gen.BadRequestError{Message: "некорректный формат даты, ожидается YYYY-MM-DD"})
		return
	}

	slots := service.GenerateSlots(et, date, s.bStore)
	c.JSON(http.StatusOK, slots)
}

// GuestApiCreateBooking создаёт новое бронирование
func (s *Server) GuestApiCreateBooking(c *gin.Context) {
	var req gen.CreateBookingRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gen.BadRequestError{Message: err.Error()})
		return
	}

	booking, err := service.CreateBooking(req, s.etStore, s.bStore)
	if err != nil {
		writeBookingError(c, err)
		return
	}

	c.JSON(http.StatusCreated, booking)
}

// --- Admin API ---

// AdminApiListEventTypes возвращает список всех типов событий (для владельца)
func (s *Server) AdminApiListEventTypes(c *gin.Context) {
	c.JSON(http.StatusOK, s.etStore.FindAll())
}

// AdminApiCreateEventType создаёт новый тип события
func (s *Server) AdminApiCreateEventType(c *gin.Context) {
	var req gen.CreateEventTypeRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gen.BadRequestError{Message: err.Error()})
		return
	}

	et := gen.EventType{
		Id:              req.Id,
		Name:            req.Name,
		Description:     req.Description,
		DurationMinutes: req.DurationMinutes,
	}

	if err := s.etStore.Save(et); err != nil {
		c.JSON(http.StatusBadRequest, gen.BadRequestError{Message: err.Error()})
		return
	}

	c.JSON(http.StatusCreated, et)
}

// AdminApiListBookings возвращает предстоящие бронирования, отсортированные по startTime
func (s *Server) AdminApiListBookings(c *gin.Context) {
	c.JSON(http.StatusOK, s.bStore.FindUpcoming())
}

// AdminApiDeleteBooking удаляет бронирование по id
func (s *Server) AdminApiDeleteBooking(c *gin.Context, id string) {
	if err := s.bStore.Delete(id); err != nil {
		c.JSON(http.StatusNotFound, gen.NotFoundError{Message: "бронирование не найдено: " + id})
		return
	}
	c.Status(http.StatusNoContent)
}

// writeBookingError пишет HTTP-ответ с ошибкой в зависимости от типа
func writeBookingError(c *gin.Context, err error) {
	switch e := err.(type) {
	case *service.ErrNotFound:
		c.JSON(http.StatusNotFound, gen.NotFoundError{Message: e.Message})
	case *service.ErrBadRequest:
		c.JSON(http.StatusBadRequest, gen.BadRequestError{Message: e.Message})
	case *service.ErrConflict:
		c.JSON(http.StatusConflict, gen.ConflictError{
			Message:              e.Message,
			ConflictingStartTime: e.ConflictingStartTime,
		})
	default:
		c.JSON(http.StatusInternalServerError, gen.BadRequestError{Message: "внутренняя ошибка сервера"})
	}
}
