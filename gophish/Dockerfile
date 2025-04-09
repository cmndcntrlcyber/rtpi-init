FROM golang:1.22-alpine AS builder

RUN apk add --no-cache git gcc g++ make

# Clone gophish from github
RUN git clone https://github.com/kgretzky/gophish.git /go/src/github.com/kgretzky/gophish

# Build gophish
WORKDIR /go/src/github.com/kgretzky/gophish
RUN go mod download
RUN go build -o /go/bin/gophish

# Create final image
FROM alpine:latest

# Copy binary
COPY --from=builder /go/bin/gophish /opt/gophish/gophish
COPY --from=builder /go/src/github.com/kgretzky/gophish/config.json /opt/gophish/
COPY --from=builder /go/src/github.com/kgretzky/gophish/static /opt/gophish/static
COPY --from=builder /go/src/github.com/kgretzky/gophish/templates /opt/gophish/templates

# Create data directory
RUN mkdir -p /opt/gophish/data

WORKDIR /opt/gophish

# Make gophish executable
RUN chmod +x /opt/gophish/gophish

# Modify the config to listen on 0.0.0.0 instead of 127.0.0.1
RUN sed -i 's/127.0.0.1/0.0.0.0/g' config.json

# Expose ports
EXPOSE 3333 8080

# Run gophish
CMD ["/opt/gophish/gophish"]
