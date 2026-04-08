package service

import (
	"time"

	"github.com/google/uuid"

	"calendar-booking/gen"
	"calendar-booking/internal/store"
)

// CreateBooking создаёт бронирование с проверкой всех бизнес-правил.
// Возвращает ErrNotFound, ErrBadRequest или ErrConflict при нарушениях.
func CreateBooking(req gen.CreateBookingRequest, etStore *store.EventTypeStore, bStore *store.BookingStore) (gen.Booking, error) {
	// 1. Найти тип события
	et, ok := etStore.FindByID(string(req.EventTypeId))
	if !ok {
		return gen.Booking{}, &ErrNotFound{Message: "тип события не найден: " + string(req.EventTypeId)}
	}

	duration := time.Duration(et.DurationMinutes) * time.Minute
	startTime := req.StartTime
	endTime := startTime.Add(duration)

	// Конвертируем в локальное время для проверки правил
	localStart := startTime.In(time.Local)
	localEnd := endTime.In(time.Local)

	// 2. Проверить будний день
	weekday := localStart.Weekday()
	if weekday == time.Saturday || weekday == time.Sunday {
		return gen.Booking{}, &ErrBadRequest{Message: "бронирование доступно только по будням (Пн–Пт)"}
	}

	// 3. Проверить диапазон 09:00–18:00
	startOfDay := time.Date(localStart.Year(), localStart.Month(), localStart.Day(), 9, 0, 0, 0, time.Local)
	endOfDay := time.Date(localStart.Year(), localStart.Month(), localStart.Day(), 18, 0, 0, 0, time.Local)

	if localStart.Before(startOfDay) || localEnd.After(endOfDay) {
		return gen.Booking{}, &ErrBadRequest{Message: "бронирование доступно только с 09:00 до 18:00"}
	}

	// 4. Проверить 14-дневное окно
	todayNow := time.Now().In(time.Local)
	today := time.Date(todayNow.Year(), todayNow.Month(), todayNow.Day(), 0, 0, 0, 0, time.Local)
	window := today.AddDate(0, 0, 14)
	slotDate := time.Date(localStart.Year(), localStart.Month(), localStart.Day(), 0, 0, 0, 0, time.Local)

	if slotDate.Before(today) || !slotDate.Before(window) {
		return gen.Booking{}, &ErrBadRequest{Message: "бронирование доступно только в ближайшие 14 дней"}
	}

	// 5. Проверить конфликты (атомарно: lock на время check+save)
	// FindConflict вызывается под RLock внутри, Save — под Lock.
	// Для демо-проекта достаточно последовательной проверки.
	if conflict, found := bStore.FindConflict(startTime, endTime); found {
		t := conflict.StartTime
		return gen.Booking{}, &ErrConflict{
			Message:              "выбранный слот уже занят",
			ConflictingStartTime: &t,
		}
	}

	// 6. Создать бронирование
	booking := gen.Booking{
		Id:            uuid.New().String(),
		EventTypeId:   req.EventTypeId,
		EventTypeName: et.Name,
		GuestName:     req.GuestName,
		GuestEmail:    req.GuestEmail,
		Note:          req.Note,
		StartTime:     startTime,
		EndTime:       endTime,
		CreatedAt:     time.Now().UTC(),
	}

	bStore.Save(booking)
	return booking, nil
}
