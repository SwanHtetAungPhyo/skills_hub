FROM golang:1.24.3-alpine

WORKDIR /app
COPY ../../myapp .
RUN go mod tidy
RUN go build -o main main.go

EXPOSE 3000
CMD ["./main"]