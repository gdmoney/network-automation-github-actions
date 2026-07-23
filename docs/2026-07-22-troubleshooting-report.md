# Troubleshooting Report: GitHub Actions → Unimus Config Push Pipeline

**Date:** 2026-07-22
**Symptom:** GitHub Actions workflows completed successfully (green), but device configurations were never applied. No push jobs appeared in Unimus.

## Environment

The pipeline runs on a NAS (`nas-network`, 192.168.255.5) hosting five Docker containers on a user-defined bridge network (172.18.0.0/16, interface `br-3f2d8f55b0de`): the GitHub Actions self-hosted runner + tftpd-hpa (`ubuntu`), Unimus 2.9.1 (published on host port 8085), Portainer, a Datadog agent, and a NetBeez agent. A workflow push triggers the runner, which executes a deploy script that calls the Unimus API (`POST /api/v3/jobs/push`). Unimus then instructs the tagged device to run `config replace tftp://<server>/<config_file> force` — the device fetches its config from the tftpd server over TFTP. The LAN has a static route for 172.18.0.0/16 via 192.168.255.5.

## Root Causes

Four independent bugs stacked on top of each other. Any one of them broke the pipeline; the second one hid the rest.

### Bug 1: Unimus API token lacked push permission

The API token had "MCP API job execution" (MCP = Mass Config Push) disabled in Unimus → User management → API tokens. Every call to `/api/v3/jobs/push` returned **HTTP 403 with an empty body**. A read-only call (`/api/v2/health`) returned 200, which made the token look valid.

**Fix:** Edit the token in Unimus and enable **MCP API job execution**.

### Bug 2: Silent failure — curl never fails a workflow

The deploy scripts called `curl` bare. curl exits 0 on HTTP 4xx/5xx unless told otherwise, and the scripts never inspected the response, so GitHub Actions reported success on every failed push. This is why Bug 1 went unnoticed.

**Fix:** Scripts now capture the HTTP status (`curl -sS -o <file> -w '%{http_code}'`), print status and response body into the Actions log, and `exit 1` on any non-2xx status, a response without `jobUuid`, or a job with zero accepted tasks.

### Bug 3: Authorization header inconsistency

Unimus requires `Authorization: Bearer <token>`. `_router_1.sh` sent the raw secret with no prefix; the other three scripts hardcoded the prefix. When the prefix was added to the GitHub secret to fix router_1, the other three scripts would have sent `Bearer Bearer <token>`.

**Fix:** All scripts now normalize the token so either secret format works:

```bash
AUTH_TOKEN="Bearer ${AUTH_TOKEN#Bearer }"
```

### Bug 4: Routers could not reach the TFTP server

The script resolved the TFTP server as the container hostname, yielding the Docker bridge IP (e.g. 172.18.0.4). Router pings and TFTP requests to that IP failed even with the LAN static route in place, for two reasons:

1. **Vendor raw-table DROP rules.** The NAS firmware installs per-container rules in `iptables -t raw PREROUTING`: `DROP !br-3f2d8f55b0de -d <container-ip>` — dropping all traffic to each container that doesn't originate on the bridge itself, before any forwarding logic runs. This was found by inserting a target-less counter rule in the raw table and observing arriving packets that never reached the FORWARD chain.
2. **Docker forwarding defaults.** Docker's FORWARD chain only admits established flows and published ports.

Diagnostic detail: after ACCEPT rules were added, the TFTP transfer worked even though the data packets return masqueraded from the host IP (the router logged "Loading ... from 192.168.255.5" while fetching from 172.18.0.4) — IOS tolerates the source IP mismatch, so no conntrack TFTP helper was needed.

**Fix:** Allow trusted sources ahead of the vendor DROPs, and open Docker forwarding for the subnet:

```bash
# Raw table - exempt trusted sources from the vendor per-container DROPs
iptables -t raw -I PREROUTING 1 -s 192.168.254.1   -d 172.18.0.0/16 -j ACCEPT
iptables -t raw -I PREROUTING 2 -s 192.168.254.5   -d 172.18.0.0/16 -j ACCEPT
iptables -t raw -I PREROUTING 3 -s 192.168.255.0/24 -d 172.18.0.0/16 -j ACCEPT

# DOCKER-USER - allow forwarding to the containers and back
iptables -I DOCKER-USER -d 172.18.0.0/16 -j ACCEPT
iptables -I DOCKER-USER -s 172.18.0.0/16 -j ACCEPT
```

## Persistence and Boot Automation

None of the iptables rules survive a reboot, container IPs are dynamically assigned (they shuffled after the first reboot test), and tftpd + the Actions runner previously had to be started manually inside the container.

- **`host-setup/container-network-rules.sh`** (installed at `/usr/local/sbin/`): idempotently re-applies all five iptables rules (each checked with `-C` before insertion), then starts tftpd-hpa and the Actions runner inside the `ubuntu` container via `docker exec` — skipping anything already running (`pgrep in.tftpd` / `pgrep -f Runner.Listener`).
- **`host-setup/container-network-rules.service`**: oneshot systemd unit that runs the script.
- **`host-setup/container-network-rules.timer`**: fires the unit **3 minutes after boot**. A hard `Requires=docker.service` dependency failed on this NAS because Docker is socket-activated (disabled unit, started on demand) — the dependency check ran 8 seconds before Docker came up. The delay also guarantees the vendor's DROP rules exist before our ACCEPTs are inserted above them.

Install:

```bash
sudo cp container-network-rules.sh /usr/local/sbin/ && sudo chmod +x /usr/local/sbin/container-network-rules.sh
sudo cp container-network-rules.service container-network-rules.timer /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable container-network-rules.timer
```

Verified by reboot: rules, tftpd, and the runner all came back with no manual intervention.

### Static container IP

Router configs reference the Datadog agent container by IP, which is dynamic. Pinned it (persists across restarts; works live on user-defined networks only):

```bash
sudo docker network disconnect <network-name> dd-agent
sudo docker network connect --ip 172.18.0.6 <network-name> dd-agent
```

The same is recommended for the `ubuntu` runner container so the TFTP source IP never moves.

## Other Changes

- All four workflow files: `actions/checkout@v4` → `@v5` (clears the Node.js 20 deprecation warning).
- Cleaned up duplicate/diagnostic iptables rules left over from debugging.

## Useful Diagnostic Commands

```bash
# Test Unimus API auth (read-only)
curl -i -H "Authorization: Bearer <TOKEN>" "http://192.168.255.5:8085/api/v2/health"

# Test push endpoint harmlessly (no config change)
curl -i -X POST "http://192.168.255.5:8085/api/v3/jobs/push" \
  -H "Authorization: Bearer <TOKEN>" -H 'Content-Type: application/json' \
  -d '{"commands":["show clock"],"tagUuids":["<TAG_UUID>"]}'

# Verify iptables FW rules on the NAS appliance
sudo iptables -t raw -L PREROUTING -n -v --line-numbers
sudo iptables -L DOCKER-USER -n -v --line-numbers

# Count packets without affecting them (target-less rule = counter only)
sudo iptables -t raw -I PREROUTING 1 -p icmp -d <container-ip>
sudo iptables -t raw -L PREROUTING -n -v --line-numbers

# Current container IP
sudo docker inspect <container> --format '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}'

# TFTP test from a Cisco device (discards output, proves reachability)
copy tftp://<server-ip>/<config_file> null:
```

## Verification (end state)

A push to a config file triggers the workflow; the Actions log shows `HTTP status: 200`, the Unimus response with `jobUuid` and accepted tasks, and `Push job submitted successfully`. The job appears in Unimus → Mass config push and the device applies the config via TFTP. Any failure (bad token, missing permission, unreachable API, rejected tasks) turns the workflow red with the status and response printed in the log.
