# Server OS — Deployment Guide

## Roles

Set `SERVER_ROLE` in `/etc/sorabbyngo/server-os.conf`:

| Role | Description |
|---|---|
| `hospital_server` | Novela backend + patient records |
| `byngox_prime` | H100/A100 vLLM inference cluster |
| `byngonet_hub` | Regional mesh intelligence hub |
| `city_node` | Smart city services |

## Byngox Prime Setup

```bash
# Install vLLM
pip install vllm

# Pull models
ollama pull deepseek-r1:70b
ollama pull mixtral:8x22b

# Start Prime cluster
systemctl start sorabbyngo-prime
systemctl start sorabbyngo-dmz
```

## NATS Clustering

```bash
# On node 1
nats-server -c /etc/sorabbyngo/nats/cluster.conf \
    --cluster nats://0.0.0.0:6222 \
    --routes nats://node2:6222,nats://node3:6222

# Verify cluster
nats server ls
```
