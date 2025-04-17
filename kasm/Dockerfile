FROM ubuntu:20.04

# Install dependencies
RUN apt-get update && apt-get install -y \
    curl \
    tar \
    sudo \
    wget \
    gnupg2 \
    ca-certificates \
    lsb-release \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /tmp

# Download Kasm installation files
RUN curl -O https://kasm-static-content.s3.amazonaws.com/kasm_release_1.15.0.06fdc8.tar.gz \
    && curl -O https://kasm-static-content.s3.amazonaws.com/kasm_release_service_images_amd64_1.15.0.06fdc8.tar.gz \
    && curl -O https://kasm-static-content.s3.amazonaws.com/kasm_release_workspace_images_amd64_1.15.0.06fdc8.tar.gz \
    && tar -xf kasm_release_1.15.0.06fdc8.tar.gz

# Fix installation script formatting issue
RUN cd kasm_release && \
    grep -l -- "--install-depends" ./*.sh | xargs sed -i 's/0.682 --install-depends/0.682 | --install-depends/g'

# Install Kasm
RUN cd kasm_release && \
    ./install.sh --accept-eula --external-database --offline-workspaces /tmp/kasm_release_workspace_images_amd64_1.15.0.06fdc8.tar.gz --offline-service /tmp/kasm_release_service_images_amd64_1.15.0.06fdc8.tar.gz --no-start

# Copy start script
COPY start.sh /start.sh
RUN chmod +x /start.sh

# Expose ports
EXPOSE 443

# Set environment variables
ENV PUBLIC_IP=0.0.0.0
ENV KASM_PORT=443

# Start Kasm services
CMD ["/start.sh"]
