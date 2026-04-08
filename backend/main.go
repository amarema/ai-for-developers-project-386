package main

import (
	"log"

	"github.com/gin-contrib/cors"
	"github.com/gin-gonic/gin"

	"calendar-booking/gen"
	"calendar-booking/internal/handler"
	"calendar-booking/internal/store"
)

func main() {
	// Инициализация хранилищ в памяти
	etStore := store.NewEventTypeStore()
	bStore := store.NewBookingStore()

	// Настройка Gin
	r := gin.Default()

	// CORS — разрешить запросы с фронтенда
	r.Use(cors.New(cors.Config{
		AllowOrigins: []string{"http://localhost:5173"},
		AllowMethods: []string{"GET", "POST", "OPTIONS"},
		AllowHeaders: []string{"Content-Type"},
	}))

	// Регистрация маршрутов через сгенерированную функцию
	srv := handler.NewServer(etStore, bStore)
	gen.RegisterHandlers(r, srv)

	log.Println("Сервер запущен на :8080")
	if err := r.Run(":8080"); err != nil {
		log.Fatal(err)
	}
}
