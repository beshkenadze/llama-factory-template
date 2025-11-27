# LLaMA Factory Template for Vast.ai

Pre-configured Docker images for VLM fine-tuning on Vast.ai with LLaMA Factory.

## Available Images

| Tag | Base Image | Description |
|-----|------------|-------------|
| `latest` | `hiyouga/llamafactory` | Full LLaMA Factory with custom tools |
| `vastai` | `vastai/base-image` | Vast.ai native features + LLaMA Factory |

## Features

### Both Images
- LLaMA Factory for fine-tuning
- Flash Attention 2.7.4
- Wandb & MLflow integration
- TensorBoard

### `latest` (LLaMA Factory Base)
- Based on `hiyouga/llamafactory:0.9.4`
- Syncthing for file sync
- UV package manager

### `vastai` (Vast.ai Base)
- Instance Portal with TLS & authentication
- Jupyter notebook built-in
- Vast CLI tools
- Cloudflare tunnel support

## Quick Start

### LLaMA Factory Image (latest)

```bash
docker pull beshkenadze/llama-factory-template:latest

docker run --gpus all -it \
  -v $(pwd):/workspace \
  -p 6006:6006 -p 8384:8384 \
  beshkenadze/llama-factory-template:latest
```

### Vast.ai Image

```bash
docker pull beshkenadze/llama-factory-template:vastai
```

On Vast.ai:
1. Create new instance with custom Docker image
2. Image: `beshkenadze/llama-factory-template:vastai`
3. All Vast.ai portal features work automatically

## Ports

| Port  | Service     | Image |
|-------|-------------|-------|
| 6006  | TensorBoard | Both |
| 8384  | Syncthing   | latest |
| 22000 | Syncthing   | latest |

## Training Example

```bash
llamafactory-cli train configs/your_config.yaml
```

## Environment Variables

| Variable | Description |
|----------|-------------|
| `WANDB_API_KEY` | Auto-login to Weights & Biases |

### Syncthing Auto-Configuration

Auto-sync with your NAS or remote server:

| Variable | Default | Description |
|----------|---------|-------------|
| `SYNCTHING_REMOTE_DEVICE_ID` | - | Remote device ID (required for auto-config) |
| `SYNCTHING_REMOTE_DEVICE_NAME` | `remote` | Name for remote device |
| `SYNCTHING_MODELS_PATH` | - | Path for models folder (receive only) |
| `SYNCTHING_MODELS_FOLDER_ID` | `models` | Folder ID for models |
| `SYNCTHING_MODELS_TYPE` | `receiveonly` | Sync type: receiveonly, sendonly, sendreceive |
| `SYNCTHING_OUTPUTS_PATH` | - | Path for outputs folder (send only) |
| `SYNCTHING_OUTPUTS_FOLDER_ID` | `outputs` | Folder ID for outputs |
| `SYNCTHING_OUTPUTS_TYPE` | `sendonly` | Sync type for outputs |

#### Example: Sync with NAS

```bash
docker run --gpus all -it \
  -e SYNCTHING_REMOTE_DEVICE_ID="XXXXXXX-XXXXXXX-XXXXXXX-XXXXXXX-XXXXXXX-XXXXXXX-XXXXXXX-XXXXXXX" \
  -e SYNCTHING_REMOTE_DEVICE_NAME="nas" \
  -e SYNCTHING_MODELS_PATH="/workspace/models" \
  -e SYNCTHING_OUTPUTS_PATH="/workspace/outputs" \
  -p 8384:8384 -p 22000:22000 \
  beshkenadze/llama-factory-template:latest
```

On NAS, configure:
- `/media/models` → sendonly (sends models to Vast)
- `/media/outputs` → receiveonly (receives results from Vast)

## Supported Models

- Qwen2-VL (2B, 7B, 72B)
- Qwen2.5-VL (3B, 7B, 72B)
- LLaMA 3
- And many more via LLaMA Factory

## Build from Source

### LLaMA Factory Image

```bash
docker build -t llama-factory-template .
```

| Argument | Default | Description |
|----------|---------|-------------|
| `LLAMAFACTORY_VERSION` | `0.9.4` | LLaMA Factory base image version |
| `FLASH_ATTN_VERSION` | `2.7.4` | Flash Attention version |
| `USER_ID` | `1000` | UID for non-root user |
| `GROUP_ID` | `1000` | GID for non-root user |

### Vast.ai Image

```bash
docker build -f Dockerfile.vastai -t llama-factory-template:vastai .
```

| Argument | Default | Description |
|----------|---------|-------------|
| `VASTAI_VERSION` | `cuda-12.4.1-auto` | Vast.ai base image tag |
| `FLASH_ATTN_VERSION` | `2.7.4` | Flash Attention version |

## License

MIT
