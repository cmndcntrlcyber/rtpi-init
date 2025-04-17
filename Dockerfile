FROM alpine:latest

LABEL maintainer="RTPI Team"
LABEL description="Base image for RTPI penetration testing tools"

# Install basic utilities
RUN apk update && \
    apk upgrade && \
    apk add --no-cache \
    bash \
    curl \
    wget \
    tar \
    git \
    nano \
    sudo \
    ca-certificates

# Create directory for RTPI tools
RUN mkdir -p /opt/rtpi-pen/

WORKDIR /opt/rtpi-pen/

# Set up environment
ENV PATH="/opt/rtpi-pen:${PATH}"

# Default command
CMD ["/bin/bash"]
