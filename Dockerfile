# Сборка фронтенда
FROM node:22-alpine AS frontend-builder
WORKDIR /app
COPY frontend/package*.json ./
RUN npm ci
COPY frontend/ .
RUN VITE_API_BASE_URL="" npm run build

# Сборка Go-бэкенда
FROM golang:1.26-alpine AS backend-builder
WORKDIR /app
COPY backend/go.mod backend/go.sum ./
RUN go mod download
COPY backend/ .
RUN CGO_ENABLED=0 GOOS=linux go build -ldflags="-s -w" -o server .

# Минимальный runtime-образ
FROM alpine:3.20
RUN apk --no-cache add ca-certificates
WORKDIR /app
COPY --from=backend-builder /app/server .
COPY --from=frontend-builder /app/build ./static
EXPOSE 8080
ENTRYPOINT ["/app/server"]
