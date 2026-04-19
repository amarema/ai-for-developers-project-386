package service

import (
	"time"

	"calendar-booking/gen"
	"calendar-booking/internal/store"
)

// GenerateAvailableDays возвращает список дат (YYYY-MM-DD) в ближайшие 14 дней,
// в которые есть хотя бы один свободный слот (будни, 09:00–18:00).
func GenerateAvailableDays(et gen.EventType, bStore *store.BookingStore) []string {
	duration := time.Duration(et.DurationMinutes) * time.Minute
	now := time.Now().In(time.Local)
	today := time.Date(now.Year(), now.Month(), now.Day(), 0, 0, 0, 0, time.Local)
	dates := make([]string, 0)

	for day := 0; day < 14; day++ {
		date := today.AddDate(0, 0, day)

		// Пропускаем выходные
		weekday := date.Weekday()
		if weekday == time.Saturday || weekday == time.Sunday {
			continue
		}

		// Проверяем наличие хотя бы одного свободного слота в этот день
		dayStart := time.Date(date.Year(), date.Month(), date.Day(), 9, 0, 0, 0, time.Local)
		dayEnd := time.Date(date.Year(), date.Month(), date.Day(), 18, 0, 0, 0, time.Local)

		for slotStart := dayStart; !slotStart.Add(duration).After(dayEnd); slotStart = slotStart.Add(duration) {
			_, conflict := bStore.FindConflict(slotStart.UTC(), slotStart.Add(duration).UTC())
			if !conflict {
				dates = append(dates, date.Format("2006-01-02"))
				break
			}
		}
	}

	return dates
}

// GenerateSlots возвращает только свободные слоты для конкретной даты.
// date — начало дня (00:00:00) в локальном времени сервера.
func GenerateSlots(et gen.EventType, date time.Time, bStore *store.BookingStore) []gen.Slot {
	duration := time.Duration(et.DurationMinutes) * time.Minute
	slots := make([]gen.Slot, 0)

	dayStart := time.Date(date.Year(), date.Month(), date.Day(), 9, 0, 0, 0, time.Local)
	dayEnd := time.Date(date.Year(), date.Month(), date.Day(), 18, 0, 0, 0, time.Local)

	for slotStart := dayStart; !slotStart.Add(duration).After(dayEnd); slotStart = slotStart.Add(duration) {
		slotEnd := slotStart.Add(duration)
		_, conflict := bStore.FindConflict(slotStart.UTC(), slotEnd.UTC())
		if !conflict {
			slots = append(slots, gen.Slot{
				StartTime: slotStart.UTC(),
				EndTime:   slotEnd.UTC(),
			})
		}
	}

	return slots
}
