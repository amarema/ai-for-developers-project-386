package service

import "time"

// ErrNotFound — тип события не найден
type ErrNotFound struct {
	Message string
}

func (e *ErrNotFound) Error() string { return e.Message }

// ErrConflict — слот уже занят
type ErrConflict struct {
	Message              string
	ConflictingStartTime *time.Time
}

func (e *ErrConflict) Error() string { return e.Message }

// ErrBadRequest — некорректные входные данные
type ErrBadRequest struct {
	Message string
}

func (e *ErrBadRequest) Error() string { return e.Message }
