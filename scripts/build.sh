#!/usr/bin/env bash
# Server OS — Infrastructure Image Builder
set -euo pipefail

WHITE='\033[1;37m'; CYAN='\033[0;36m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; NC='\033[0m'; BOLD='\033[1m'
info()    { echo -e "${CYAN}[server-os]${NC} $*"; }
success() { echo -e "${GREEN}[server-os]${NC} $*"; }
warn()    { echo -e "${YELLOW}[server-os]${NC} $*"; }

KERNEL_SRC="${KERNEL_SRC:-$HOME/sorabbyngo-os}"
DEFCONFIG="sorabbyngo_server_defconfig"
OUTPUT="${OUTPUT:-$HOME/server-os/build}"
ROLE="${ROLE:-hospital}"   # hospital | prime | regional | city

echo -e "${BOLD}"
cat << 'BANNER'
  ╔══════════════════════════════════════╗
  ║  Server OS — Infrastructure Builder  ║
  ║  vLLM · NATS · XDP · High Throughput ║
  ╚══════════════════════════════════════╝
BANNER
echo -e "${NC}"

[[ ! -d "$KERNEL_SRC" ]] && { warn "Kernel source not at $KERNEL_SRC"; exit 1; }

info "Role: $ROLE"
info "Applying server defconfig..."
cp defconfig/$DEFCONFIG "$KERNEL_SRC/arch/x86/configs/"
make -C "$KERNEL_SRC" $DEFCONFIG
success "Server defconfig applied"

info "Building high-throughput kernel..."
make -C "$KERNEL_SRC" -j$(nproc) bzImage modules
success "Kernel built"

info "Overlaying Server OS rootfs..."
mkdir -p "$OUTPUT"
cp -r rootfs/* "$OUTPUT/"

info "Installing systemd units for role: $ROLE"
UNITS=(cyberwall-server.service nats-cluster.service byngonet-server.service dmz-gateway.service server.target)
for unit in "${UNITS[@]}"; do
    cp rootfs/etc/systemd/system/$unit "$OUTPUT/etc/systemd/system/"
done

case "$ROLE" in
    hospital)
        info "Hospital role — Novela backend + Byngox Prime"
        systemctl --root="$OUTPUT" enable cyberwall-server.service
        systemctl --root="$OUTPUT" enable nats-cluster.service
        systemctl --root="$OUTPUT" enable byngox-prime.service
        systemctl --root="$OUTPUT" enable byngonet-server.service
        systemctl --root="$OUTPUT" enable dmz-gateway.service
        ;;
    prime)
        info "Prime role — Byngox Prime inference cluster only"
        systemctl --root="$OUTPUT" enable cyberwall-server.service
        systemctl --root="$OUTPUT" enable nats-cluster.service
        systemctl --root="$OUTPUT" enable byngox-prime.service
        ;;
    regional)
        info "Regional role — Byngonet regional hub"
        systemctl --root="$OUTPUT" enable cyberwall-server.service
        systemctl --root="$OUTPUT" enable nats-cluster.service
        systemctl --root="$OUTPUT" enable byngonet-server.service
        systemctl --root="$OUTPUT" enable dmz-gateway.service
        ;;
    city)
        info "City role — Smart city infrastructure node"
        systemctl --root="$OUTPUT" enable cyberwall-server.service
        systemctl --root="$OUTPUT" enable nats-cluster.service
        systemctl --root="$OUTPUT" enable byngonet-server.service
        ;;
esac

systemctl --root="$OUTPUT" set-default server.target
success "Server OS ($ROLE) image ready at $OUTPUT"
