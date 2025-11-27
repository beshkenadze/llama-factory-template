# LLaMA Factory Template for Vast.ai

Pre-configured Docker image for VLM fine-tuning on Vast.ai with LLaMA Factory.

## Features

- Based on `hiyouga/llamafactory:latest`
- TensorBoard for training visualization
- Syncthing for file synchronization
- Flash Attention 2.7.4 (CUDA 12.4, PyTorch 2.5)
- UV package manager

## Ports

| Port  | Service     |
|-------|-------------|
| 6006  | TensorBoard |
| 8384  | Syncthing   |
| 22000 | Syncthing   |

## Quick Start

### Pull from Docker Hub

```bash
docker pull beshkenadze/llama-factory-template:latest
```

### Run locally

```bash
docker run --gpus all -it \
  -v $(pwd):/workspace \
  -p 6006:6006 -p 8384:8384 \
  beshkenadze/llama-factory-template:latest
```

### Use on Vast.ai

1. Create new instance with custom Docker image
2. Image: `beshkenadze/llama-factory-template:latest`
3. Open ports: 6006, 8384, 22000

## Training Example

```bash
# Inside container
llamafactory-cli train configs/your_config.yaml
```

## Supported Models

- Qwen2-VL (2B, 7B, 72B)
- Qwen2.5-VL (3B, 7B, 72B)
- LLaMA 3
- And many more via LLaMA Factory

## Build from Source

```bash
docker build -t llama-factory-template .
```

### Build Arguments

| Argument | Default | Description |
|----------|---------|-------------|
| `LLAMAFACTORY_VERSION` | `0.9.4` | LLaMA Factory base image version |
| `FLASH_ATTN_VERSION` | `2.7.4` | Flash Attention version (for logging) |
| `USER_ID` | `1000` | UID for non-root user |
| `GROUP_ID` | `1000` | GID for non-root user |

```bash
docker build --build-arg LLAMAFACTORY_VERSION=0.9.4 -t llama-factory-template .
```

## License

MIT
