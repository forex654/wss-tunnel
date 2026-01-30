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

# 使用 shell 形式的 CMD，这样可以解析环境变量
CMD /proxy -l wss://0.0.0.0:8080/ws -token "${TOKEN}"
