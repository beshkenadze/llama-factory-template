# Vast.ai Template: LLaMA Factory + TensorBoard + Syncthing
ARG LLAMAFACTORY_VERSION=0.9.4
FROM hiyouga/llamafactory:${LLAMAFACTORY_VERSION}

ENV DEBIAN_FRONTEND=noninteractive

# Install curl, syncthing, tmux, uv
RUN apt-get update && apt-get install -y --no-install-recommends curl ca-certificates gnupg tmux && \
    curl -fsSL https://syncthing.net/release-key.gpg | gpg --dearmor -o /usr/share/keyrings/syncthing-archive-keyring.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/syncthing-archive-keyring.gpg] https://apt.syncthing.net/ syncthing stable" > /etc/apt/sources.list.d/syncthing.list && \
    apt-get update && apt-get install -y --no-install-recommends syncthing && \
    curl -LsSf https://astral.sh/uv/install.sh | sh && \
    apt-get purge -y gnupg && apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ENV PATH="/root/.local/bin:$PATH"

# Create non-root user for security (with sudo access for flexibility)
ARG USER_ID=1000
ARG GROUP_ID=1000
RUN groupadd -g ${GROUP_ID} llama && \
    useradd -m -u ${USER_ID} -g llama -s /bin/bash llama && \
    echo "llama ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Install logging/tracking tools (tensorboard, wandb, mlflow) + flash-attention
ARG FLASH_ATTN_VERSION=2.7.4
ARG FLASH_ATTN_WHEEL=https://github.com/mjun0812/flash-attention-prebuild-wheels/releases/download/v0.5.4/flash_attn-2.7.4%2Bcu124torch2.5-cp311-cp311-linux_x86_64.whl
RUN uv pip install --system tensorboard wandb mlflow "optimum>=1.24.0" && \
    (uv pip install --system --no-deps ${FLASH_ATTN_WHEEL} \
    || echo "WARNING: flash-attention ${FLASH_ATTN_VERSION} install failed - continuing without it") && \
    (uv pip install --system --no-deps "gptqmodel>=2.0.0" logbar \
    || echo "WARNING: gptqmodel install failed - install at runtime with: uv pip install --system --no-deps gptqmodel logbar") && \
    rm -rf /root/.cache/pip /root/.cache/uv /tmp/*

WORKDIR /workspace

# Ports: TensorBoard(6006), Syncthing(8384, 22000)
EXPOSE 6006 8384 22000

# Ensure workspace is accessible by non-root user
RUN mkdir -p /workspace && chown -R llama:llama /workspace

# Copy Syncthing config script
COPY scripts/syncthing-config.sh /opt/syncthing-config.sh
RUN chmod +x /opt/syncthing-config.sh

# Startup script
COPY scripts/startup.sh /opt/startup.sh
RUN chmod +x /opt/startup.sh

# Switch to non-root user
USER llama
ENV HOME=/home/llama
ENV PATH="/home/llama/.local/bin:${PATH}"

ENTRYPOINT ["/opt/startup.sh"]
CMD ["bash"]
