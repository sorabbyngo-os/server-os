<p align="center">
  <img src="https://raw.githubusercontent.com/sorabbyngo-Labs/.github/main/assets/sorabbyngo-logo.jpg" alt="Sorabbyngo" width="480"/>
</p>

<p align="center">
  <strong>Server OS — Infrastructure & Data Center Operating System</strong>
</p>

<p align="center">
  Built on Sorabbyngo AI Kernel · High availability · vLLM · Byngonet node
</p>

---

## What this is

Server OS is the infrastructure surface of the Sorabbyngo AI Kernel. It powers hospital servers, Byngonet regional nodes, Byngox Prime inference clusters, and data centers.

---

## Key Features

| Feature | Implementation |
|---|---|
| High throughput | XDP networking, io_uring |
| AI inference | vLLM server — Byngox Prime cluster |
| Message bus | NATS JetStream clustering |
| Data integrity | ZFS / Btrfs |
| Out-of-band management | IPMI support |
| Byngonet node | Regional intelligence hub |

---

## Relationship to Sorabbyngo Kernel
sorabbyngo-os (kernel source)
└── configs/sorabbyngo_server_defconfig
└── server-os (this repo — server rootfs + vLLM + NATS)

---

## Target Deployments

| Deployment | Role |
|---|---|
| Hospital server | Novela backend + patient records |
| Byngox Prime cluster | H100/A100 vLLM inference |
| Byngonet regional node | Intelligence mesh hub |
| City infrastructure node | Smart city services |

---

## Related Repositories

| Repo | Role |
|---|---|
| [sorabbyngo-os](https://github.com/sorabbyngo-Labs/sorabbyngo-os) | Kernel source |
| [byngox](https://github.com/sorabbyngo-Labs/byngox) | AI reasoning — Byngox Prime |
| [byngonet](https://github.com/sorabbyngo-Labs/byngonet) | Regional mesh node |
| [novela](https://github.com/sorabbyngo-Labs/novela) | Health platform backend |

---

**Sorabbyngo Company** · Kisii, Kenya · 2026
*Rhythm of Digital Life*
