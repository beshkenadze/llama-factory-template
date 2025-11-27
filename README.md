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
