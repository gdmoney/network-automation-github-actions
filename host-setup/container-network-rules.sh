#!/bin/bash
# Restores the iptables rules that allow trusted network devices to reach
# the Docker containers (TFTP/Unimus automation) after a reboot.
#
# Install:
#   sudo cp container-network-rules.sh /usr/local/sbin/
#   sudo chmod +x /usr/local/sbin/container-network-rules.sh
#   sudo cp container-network-rules.service /etc/systemd/system/
#   sudo systemctl daemon-reload
#   sudo systemctl enable container-network-rules.service
#
# Each rule is checked (-C) before insertion, so re-running is safe.

DOCKER_SUBNET="172.18.0.0/16"
TRUSTED_SOURCES=("192.168.254.1" "192.168.254.5" "192.168.255.0/24")

# Wait for Docker to create the DOCKER-USER chain (up to 60s)
for i in $(seq 1 12); do
  iptables -L DOCKER-USER -n >/dev/null 2>&1 && break
  sleep 5
done

# Raw table: exempt trusted sources from the per-container DROP rules.
# Inserted at position 1 so they sit above any vendor DROPs.
for SRC in "${TRUSTED_SOURCES[@]}"; do
  iptables -t raw -C PREROUTING -s "${SRC}" -d "${DOCKER_SUBNET}" -j ACCEPT 2>/dev/null \
    || iptables -t raw -I PREROUTING 1 -s "${SRC}" -d "${DOCKER_SUBNET}" -j ACCEPT
done

# DOCKER-USER: allow forwarding to the containers and back.
iptables -C DOCKER-USER -d "${DOCKER_SUBNET}" -j ACCEPT 2>/dev/null \
  || iptables -I DOCKER-USER -d "${DOCKER_SUBNET}" -j ACCEPT
iptables -C DOCKER-USER -s "${DOCKER_SUBNET}" -j ACCEPT 2>/dev/null \
  || iptables -I DOCKER-USER -s "${DOCKER_SUBNET}" -j ACCEPT

echo "Container network rules applied."
