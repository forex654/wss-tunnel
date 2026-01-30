FROM golang:1.23-alpine AS builder

WORKDIR /app

RUN apk add --no-cache git ca-certificates

COPY main.go .

RUN go mod init proxy
RUN go mod tidy
RUN go get github.com/google/uuid@latest
RUN go get github.com/gorilla/websocket@latest
RUN go mod tidy

RUN CGO_ENABLED=0 GOOS=linux go build -ldflags="-s -w" -o proxy main.go

FROM alpine:latest

RUN apk add --no-cache ca-certificates tzdata

COPY --from=builder /app/proxy /proxy

EXPOSE 8080

# 启动命令写在这里，自动使用 $PORT 环境变量
CMD ["sh", "-c", "/proxy -l ws://0.0.0.0:$PORT/ws"]
