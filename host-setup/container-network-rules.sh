#!/bin/bash
# Restores the iptables rules that allow trusted network devices to reach
# the Docker containers (TFTP/Unimus automation) after a reboot.
#
# Install:
#   sudo cp container-network-rules.sh /usr/local/sbin/
#   sudo chmod +x /usr/local/sbin/container-network-rules.sh
#   sudo cp container-network-rules.service container-network-rules.timer /etc/systemd/system/
#   sudo systemctl daemon-reload
#   sudo systemctl enable container-network-rules.timer
#
# The timer fires 3 minutes after boot - a hard dependency on docker.service
# does not work on this NAS (Docker is socket-activated), and the vendor
# firewall's per-container DROP rules need to exist before ours go on top.
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

# --- Start services inside the runner container -----------------------------
RUNNER_CONTAINER="ubuntu"

# Wait for the container to be running (up to 60s)
for i in $(seq 1 12); do
  [ "$(docker inspect -f '{{.State.Running}}' ${RUNNER_CONTAINER} 2>/dev/null)" = "true" ] && break
  sleep 5
done

if [ "$(docker inspect -f '{{.State.Running}}' ${RUNNER_CONTAINER} 2>/dev/null)" != "true" ]; then
  echo "WARNING: container '${RUNNER_CONTAINER}' is not running - skipped service startup"
  exit 0
fi

# TFTP server (skip if already running)
docker exec ${RUNNER_CONTAINER} pgrep in.tftpd >/dev/null 2>&1 \
  || docker exec ${RUNNER_CONTAINER} /etc/init.d/tftpd-hpa start

# GitHub Actions runner as siteadmin, detached (skip if already running)
docker exec ${RUNNER_CONTAINER} pgrep -f Runner.Listener >/dev/null 2>&1 \
  || docker exec -d -u siteadmin -w /home/siteadmin/actions-runner ${RUNNER_CONTAINER} ./run.sh

echo "Container services started."
