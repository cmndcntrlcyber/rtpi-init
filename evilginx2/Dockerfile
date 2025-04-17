FROM golang:1.22-alpine

RUN apk add --no-cache git build-base

# Clone evilginx2 from GitHub
RUN git clone https://github.com/kgretzky/evilginx2.git /go/src/github.com/kgretzky/evilginx2

# Build evilginx2
WORKDIR /go/src/github.com/kgretzky/evilginx2
RUN go mod download
RUN go build -o /go/bin/evilginx main.go

# Create the final image
FROM alpine:latest

RUN apk add --no-cache ca-certificates bash

# Copy the built binary
COPY --from=0 /go/bin/evilginx /usr/local/bin/evilginx

# Copy the phishlets and other necessary files
COPY --from=0 /go/src/github.com/kgretzky/evilginx2/phishlets /opt/evilginx/phishlets
COPY --from=0 /go/src/github.com/kgretzky/evilginx2/templates /opt/evilginx/templates

# Create necessary directories
RUN mkdir -p /root/.evilginx

WORKDIR /root

# Expose ports
EXPOSE 80 443 53/udp

# Set entrypoint
ENTRYPOINT ["evilginx", "-p", "/opt/evilginx/phishlets", "-t", "/opt/evilginx/templates"]
