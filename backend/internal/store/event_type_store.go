package store

import (
	"fmt"
	"sync"

	"calendar-booking/gen"
)

// EventTypeStore — хранилище типов событий в памяти
type EventTypeStore struct {
	mu    sync.RWMutex
	items map[string]gen.EventType
}

func NewEventTypeStore() *EventTypeStore {
	return &EventTypeStore{
		items: make(map[string]gen.EventType),
	}
}

// FindAll возвращает все типы событий
func (s *EventTypeStore) FindAll() []gen.EventType {
	s.mu.RLock()
	defer s.mu.RUnlock()

	result := make([]gen.EventType, 0, len(s.items))
	for _, et := range s.items {
		result = append(result, et)
	}
	return result
}

// FindByID возвращает тип события по id или false если не найден
func (s *EventTypeStore) FindByID(id string) (gen.EventType, bool) {
	s.mu.RLock()
	defer s.mu.RUnlock()

	et, ok := s.items[id]
	return et, ok
}

// Save сохраняет тип события; возвращает ошибку если id уже занят
func (s *EventTypeStore) Save(et gen.EventType) error {
	s.mu.Lock()
	defer s.mu.Unlock()

	if _, exists := s.items[string(et.Id)]; exists {
		return fmt.Errorf("тип события с id '%s' уже существует", et.Id)
	}
	s.items[string(et.Id)] = et
	return nil
}
