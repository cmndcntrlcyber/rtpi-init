FROM golang:1.22-alpine AS builder

# Install required dependencies
RUN apk add --no-cache git build-base

# Clone evilginx2 from GitHub
RUN git clone https://github.com/kgretzky/evilginx2.git /go/src/github.com/kgretzky/evilginx2

# Build evilginx2
WORKDIR /go/src/github.com/kgretzky/evilginx2
RUN go mod download
RUN go build -o /go/bin/evilginx main.go

# Create the final image
FROM alpine:latest

# Install required packages
RUN apk add --no-cache ca-certificates bash bind-tools

# Copy the built binary
COPY --from=builder /go/bin/evilginx /usr/local/bin/evilginx

# Copy the phishlets
COPY --from=builder /go/src/github.com/kgretzky/evilginx2/phishlets /opt/evilginx/phishlets

# Create necessary directories
RUN mkdir -p /root/.evilginx

WORKDIR /root

# Expose ports
EXPOSE 80 443 53/udp

# Set entrypoint
ENTRYPOINT ["evilginx", "-p", "/opt/evilginx/phishlets"]
