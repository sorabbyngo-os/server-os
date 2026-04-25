#!/usr/bin/env bash
# Server OS — Infrastructure Image Builder
set -euo pipefail

CYAN='\033[0;36m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; NC='\033[0m'; BOLD='\033[1m'
info()    { echo -e "${CYAN}[server-os]${NC} $*"; }
success() { echo -e "${GREEN}[server-os]${NC} $*"; }
warn()    { echo -e "${YELLOW}[server-os]${NC} $*"; }

KERNEL_SRC="${KERNEL_SRC:-$HOME/sorabbyngo-os}"
DEFCONFIG="sorabbyngo_server_defconfig"
OUTPUT="${OUTPUT:-$HOME/server-os/build}"
ROLE="${ROLE:-hospital}"   # hospital | prime | regional | city

echo -e "${BOLD}"
cat << 'BANNER'
  ╔══════════════════════════════════════════╗
  ║   Server OS — Infrastructure Builder    ║
  ║   vLLM · NATS Cluster · High Throughput ║
  ╚══════════════════════════════════════════╝
BANNER
echo -e "${NC}"

[[ ! -d "$KERNEL_SRC" ]] && { warn "Kernel source not at $KERNEL_SRC"; exit 1; }

info "Role: $ROLE"
info "Applying server defconfig (XDP + io_uring)..."
cp defconfig/$DEFCONFIG "$KERNEL_SRC/arch/x86/configs/"
make -C "$KERNEL_SRC" $DEFCONFIG
success "Server defconfig applied"

info "Building server kernel..."
make -C "$KERNEL_SRC" -j$(nproc) bzImage modules
success "Kernel built"

info "Overlaying Server OS rootfs..."
mkdir -p "$OUTPUT"
cp -r rootfs/* "$OUTPUT/"
cp configs/nats-cluster.conf "$OUTPUT/etc/sorabbyngo/"
success "Rootfs overlay applied"

info "Installing systemd units for role: $ROLE"
for svc in cyberwall-server nats-cluster byngonet-regional sentinel-server; do
    cp rootfs/etc/systemd/system/$svc.service "$OUTPUT/etc/systemd/system/"
    systemctl --root="$OUTPUT" enable $svc.service
done
cp rootfs/etc/systemd/system/server.target "$OUTPUT/etc/systemd/system/"

case "$ROLE" in
    prime)
        info "Prime role — enabling Byngox Prime vLLM"
        cp rootfs/etc/systemd/system/byngox-prime.service "$OUTPUT/etc/systemd/system/"
        systemctl --root="$OUTPUT" enable byngox-prime.service
        ;;
    hospital)
        info "Hospital role — Novela backend + patient records"
        ;;
    regional)
        info "Regional node — Byngonet intelligence hub"
        ;;
    city)
        info "City infrastructure — smart city services"
        ;;
esac

systemctl --root="$OUTPUT" set-default server.target
success "Server OS ($ROLE) image ready at $OUTPUT"
