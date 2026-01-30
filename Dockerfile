FROM golang:1.22-alpine AS builder

WORKDIR /app

RUN apk add --no-cache git ca-certificates

# 创建 go.mod
COPY main.go .

RUN go mod init proxy

# 下载依赖
RUN go mod tidy || true
RUN go get github.com/google/uuid@latest
RUN go get github.com/gorilla/websocket@latest
RUN go mod tidy

# 编译
RUN CGO_ENABLED=0 GOOS=linux go build -ldflags="-s -w" -o proxy main.go

# 运行镜像
FROM alpine:latest

RUN apk add --no-cache ca-certificates tzdata

COPY --from=builder /app/proxy /proxy

EXPOSE 8080

ENV TOKEN=""
ENV PORT="8080"
ENV PATH_PREFIX="/ws"

CMD /proxy -l wss://0.0.0.0:${PORT}${PATH_PREFIX} -token ${TOKEN}
