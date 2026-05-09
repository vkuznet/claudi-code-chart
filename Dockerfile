FROM debian:bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive

# Install only what we need (no recommends)
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates curl git vim bash sudo zstd \
    iputils-ping lynx less procps net-tools links2 w3m \
    && rm -rf /var/lib/apt/lists/*

# install ollama
RUN curl -fsSL https://ollama.com/install.sh -o /tmp/install.sh \
    && chmod +x /tmp/install.sh \
    && /tmp/install.sh \
    && rm /tmp/install.sh

# Create non-root user with sudo access
RUN useradd -m -u 1000 appuser \
    && usermod -aG sudo appuser \
    && echo "appuser ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

USER appuser
WORKDIR /home/appuser

# Install Claude CLI (as non-root user)
RUN curl -fsSL https://claude.ai/install.sh -o /tmp/install.sh \
    && chmod +x /tmp/install.sh \
    && /tmp/install.sh \
    && rm /tmp/install.sh

# Ensure user-local bin is in PATH
ENV PATH="/home/appuser/.local/bin:${PATH}"

CMD ["/bin/bash"]
