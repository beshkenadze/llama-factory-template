#!/bin/bash
# Persist environment variables for Vast.ai SSH/Jupyter sessions
# Vast.ai doesn't pass env vars to SSH/Jupyter by default

# Persist HF_TOKEN and WANDB_API_KEY to /etc/environment (once)
if [ -n "$HF_TOKEN" ] && ! grep -q "^HF_TOKEN=" /etc/environment 2>/dev/null; then
    echo "HF_TOKEN=$HF_TOKEN" | sudo tee -a /etc/environment >/dev/null 2>&1 || true
fi

if [ -n "$WANDB_API_KEY" ] && ! grep -q "^WANDB_API_KEY=" /etc/environment 2>/dev/null; then
    echo "WANDB_API_KEY=$WANDB_API_KEY" | sudo tee -a /etc/environment >/dev/null 2>&1 || true
fi

# Source /etc/environment to load persisted vars
[ -f /etc/environment ] && export $(grep -E "^(HF_TOKEN|WANDB_API_KEY)=" /etc/environment | xargs) 2>/dev/null || true

# Auto-login wandb if API key is available
[ -n "$WANDB_API_KEY" ] && python -c "import wandb; wandb.login(key=\"$WANDB_API_KEY\")" 2>/dev/null || true
