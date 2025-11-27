#!/bin/bash

# Export only non-sensitive env vars for cron/subprocess compatibility
env | grep -E "^(PATH|HOME|LANG|LC_|TERM|SHELL|USER|HOSTNAME)=" >> /etc/environment 2>/dev/null || true

# Auto-login wandb if API key is set (skips interactive menu)
[ -n "$WANDB_API_KEY" ] && python -c "import wandb; wandb.login(key=\"$WANDB_API_KEY\")" 2>/dev/null || true

# Start Syncthing
syncthing --no-browser --gui-address=0.0.0.0:8384 &

# Configure Syncthing if remote device is set (runs in background)
if [ -n "$SYNCTHING_REMOTE_DEVICE_ID" ]; then
    (sleep 5 && /opt/syncthing-config.sh) &
fi

# Start TensorBoard if models directory exists
[ -d "/workspace/models" ] && tensorboard --logdir=/workspace/models --host=0.0.0.0 --port=6006 &

# Print local Syncthing Device ID for easy setup
echo ""
echo "=== Container Started ==="
echo "Syncthing Device ID: $(syncthing --device-id 2>/dev/null || echo 'starting...')"
echo "Syncthing UI: http://localhost:8384"
[ -d "/workspace/models" ] && echo "TensorBoard: http://localhost:6006"
echo ""

exec "$@"
