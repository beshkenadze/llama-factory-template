# Vast.ai Template: LLaMA Factory + TensorBoard + Syncthing
FROM hiyouga/llamafactory:latest

ENV DEBIAN_FRONTEND=noninteractive

# Install curl, syncthing, tmux, uv
RUN apt-get update && apt-get install -y --no-install-recommends curl ca-certificates gnupg tmux && \
    curl -fsSL https://syncthing.net/release-key.gpg | gpg --dearmor -o /usr/share/keyrings/syncthing-archive-keyring.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/syncthing-archive-keyring.gpg] https://apt.syncthing.net/ syncthing stable" > /etc/apt/sources.list.d/syncthing.list && \
    apt-get update && apt-get install -y --no-install-recommends syncthing && \
    curl -LsSf https://astral.sh/uv/install.sh | sh && \
    rm -rf /var/lib/apt/lists/*

ENV PATH="/root/.local/bin:$PATH"

# Install TensorBoard + flash-attention with uv
RUN uv pip install --system tensorboard && \
    uv pip install --system --no-deps \
    https://github.com/mjun0812/flash-attention-prebuild-wheels/releases/download/v0.5.4/flash_attn-2.7.4%2Bcu124torch2.5-cp311-cp311-linux_x86_64.whl \
    || true

WORKDIR /workspace

# Ports: TensorBoard(6006), Syncthing(8384, 22000)
EXPOSE 6006 8384 22000

# Startup script
RUN printf '#!/bin/bash\nenv >> /etc/environment\nsyncthing --no-browser --gui-address=0.0.0.0:8384 &\n[ -d "/workspace/models" ] && tensorboard --logdir=/workspace/models --host=0.0.0.0 --port=6006 &\nexec "$@"\n' > /opt/startup.sh && \
    chmod +x /opt/startup.sh

ENTRYPOINT ["/opt/startup.sh"]
CMD ["bash"]
