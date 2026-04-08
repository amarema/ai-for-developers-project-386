package store

import (
	"fmt"
	"sort"
	"sync"
	"time"

	"calendar-booking/gen"
)

// BookingStore — хранилище бронирований в памяти
type BookingStore struct {
	mu    sync.RWMutex
	items map[string]gen.Booking
}

func NewBookingStore() *BookingStore {
	return &BookingStore{
		items: make(map[string]gen.Booking),
	}
}

// FindAll возвращает все бронирования
func (s *BookingStore) FindAll() []gen.Booking {
	s.mu.RLock()
	defer s.mu.RUnlock()

	result := make([]gen.Booking, 0, len(s.items))
	for _, b := range s.items {
		result = append(result, b)
	}
	return result
}

// FindUpcoming возвращает предстоящие бронирования (startTime >= now), отсортированные по startTime
func (s *BookingStore) FindUpcoming() []gen.Booking {
	s.mu.RLock()
	defer s.mu.RUnlock()

	now := time.Now()
	result := make([]gen.Booking, 0)
	for _, b := range s.items {
		if !b.StartTime.Before(now) {
			result = append(result, b)
		}
	}
	sort.Slice(result, func(i, j int) bool {
		return result[i].StartTime.Before(result[j].StartTime)
	})
	return result
}

// FindConflict возвращает первое бронирование, пересекающееся с интервалом [start, end)
func (s *BookingStore) FindConflict(start, end time.Time) (gen.Booking, bool) {
	s.mu.RLock()
	defer s.mu.RUnlock()

	for _, b := range s.items {
		// Конфликт: b.StartTime < end && b.EndTime > start
		if b.StartTime.Before(end) && b.EndTime.After(start) {
			return b, true
		}
	}
	return gen.Booking{}, false
}

// Save сохраняет бронирование (под write-lock)
func (s *BookingStore) Save(b gen.Booking) {
	s.mu.Lock()
	defer s.mu.Unlock()
	s.items[b.Id] = b
}

// Delete удаляет бронирование по id. Возвращает ошибку, если не найдено.
func (s *BookingStore) Delete(id string) error {
	s.mu.Lock()
	defer s.mu.Unlock()
	if _, exists := s.items[id]; !exists {
		return fmt.Errorf("не найдено")
	}
	delete(s.items, id)
	return nil
}
