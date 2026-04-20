package main

import (
	"log"
	"os"

	"github.com/gin-contrib/cors"
	"github.com/gin-gonic/gin"

	"calendar-booking/gen"
	"calendar-booking/internal/handler"
	"calendar-booking/internal/store"
)

// seedEventTypes заполняет хранилище начальными типами событий при старте сервера
func seedEventTypes(s *store.EventTypeStore) {
	seeds := []gen.EventType{
		{
			Id:              "intro-call",
			Name:            "Первичная консультация",
			Description:     "Знакомство и обсуждение ваших задач и целей.",
			DurationMinutes: 30,
		},
		{
			Id:              "follow-up",
			Name:            "Повторная встреча",
			Description:     "Обсуждение прогресса и следующих шагов.",
			DurationMinutes: 30,
		},
		{
			Id:              "deep-dive",
			Name:            "Детальный разбор",
			Description:     "Глубокий анализ задачи или проекта.",
			DurationMinutes: 60,
		},
	}
	for _, et := range seeds {
		_ = s.Save(et)
	}
}

func main() {
	// Инициализация хранилищ в памяти
	etStore := store.NewEventTypeStore()
	seedEventTypes(etStore)
	bStore := store.NewBookingStore()

	// Настройка Gin
	r := gin.Default()

	// CORS — разрешить запросы с фронтенда (localhost и продакшн)
	allowedOrigins := []string{"http://localhost:5173"}
	if origin := os.Getenv("FRONTEND_ORIGIN"); origin != "" {
		allowedOrigins = append(allowedOrigins, origin)
	}
	r.Use(cors.New(cors.Config{
		AllowOrigins: allowedOrigins,
		AllowMethods: []string{"GET", "POST", "DELETE", "OPTIONS"},
		AllowHeaders: []string{"Content-Type"},
	}))

	// Регистрация маршрутов через сгенерированную функцию
	srv := handler.NewServer(etStore, bStore)
	gen.RegisterHandlers(r, srv)

	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}
	log.Printf("Сервер запущен на :%s", port)
	if err := r.Run(":" + port); err != nil {
		log.Fatal(err)
	}
}
