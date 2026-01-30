
FROM golang:1.22-alpine AS builder

WORKDIR /app

RUN apk add --no-cache git

RUN go mod init proxy && \
    go get github.com/google/uuid && \
    go get github.com/gorilla/websocket

COPY main.go .

RUN CGO_ENABLED=0 go build -ldflags="-s -w" -o proxy main.go

FROM alpine:latest

RUN apk add --no-cache ca-certificates tzdata

COPY --from=builder /app/proxy /proxy

EXPOSE 8080

ENV TOKEN=""
ENV PORT="8080"
ENV PATH_PREFIX="/ws"

CMD /proxy -l wss://0.0.0.0:${PORT}${PATH_PREFIX} -token ${TOKEN}
