package service

import (
	"time"

	"calendar-booking/gen"
	"calendar-booking/internal/store"
)

// GenerateSlots вычисляет доступные слоты для типа события на ближайшие 14 дней.
// Слоты генерируются по будням (Пн–Пт) с 09:00 до 18:00 по локальному времени сервера.
func GenerateSlots(et gen.EventType, bStore *store.BookingStore) []gen.Slot {
	duration := time.Duration(et.DurationMinutes) * time.Minute
	now := time.Now().In(time.Local)
	today := time.Date(now.Year(), now.Month(), now.Day(), 0, 0, 0, 0, time.Local)
	slots := make([]gen.Slot, 0)

	for day := 0; day < 14; day++ {
		date := today.AddDate(0, 0, day)

		// Пропускаем выходные
		weekday := date.Weekday()
		if weekday == time.Saturday || weekday == time.Sunday {
			continue
		}

		// Генерируем слоты от 09:00 с шагом durationMinutes
		dayStart := time.Date(date.Year(), date.Month(), date.Day(), 9, 0, 0, 0, time.Local)
		dayEnd := time.Date(date.Year(), date.Month(), date.Day(), 18, 0, 0, 0, time.Local)

		for slotStart := dayStart; !slotStart.Add(duration).After(dayEnd); slotStart = slotStart.Add(duration) {
			slotEnd := slotStart.Add(duration)

			// Проверяем доступность: нет ли пересекающихся бронирований
			_, conflict := bStore.FindConflict(slotStart.UTC(), slotEnd.UTC())

			slots = append(slots, gen.Slot{
				StartTime: slotStart.UTC(),
				EndTime:   slotEnd.UTC(),
				Available: !conflict,
			})
		}
	}

	return slots
}
