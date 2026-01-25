FROM debian:latest

RUN apt-get update && apt-get install -y \
    bash \
    sudo \
    curl \
    wget \
    git \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY scripts/ /app/scripts/
COPY config/ /app/config/
COPY install.sh /app/

RUN chmod +x /app/install.sh \
    && chmod +x /app/scripts/*.sh \
    && chmod +x /app/scripts/editions/*.sh

ENTRYPOINT ["/bin/bash"] 