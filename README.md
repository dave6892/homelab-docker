# Homelab Docker (GitOps Ready)

A Docker-based homelab setup featuring a dashboard, media server, local DNS, and reverse proxy. Designed to be deployed via **Portainer Stacks** (GitOps).

## Architecture

- **Traefik**: Reverse proxy and load balancer with HTTPS (Port 80/443).
- **Pi-hole**: Local DNS and Ad-blocking (Port 53).
- **Apps**: Homepage, Plex, Tautulli (Internal ports only, accessed via HTTPS).

## Prerequisites

### Generate SSL Certificates
Before deploying, generate self-signed certificates for HTTPS:

```bash
# On your Proxmox server or local machine
cd traefik
./generate-certs.sh
```

This creates `traefik/certs/homelab.crt` and `traefik/certs/homelab.key` valid for 10 years.

**Important**: After generating certificates, install `traefik/certs/homelab.crt` in your browser/system to avoid security warnings:
- **macOS**: Open the .crt file, add to Keychain, and set to "Always Trust"
- **Linux**: `sudo cp traefik/certs/homelab.crt /usr/local/share/ca-certificates/ && sudo update-ca-certificates`
- **Windows**: Double-click the .crt file and install to "Trusted Root Certification Authorities"

## Deployment via Portainer

Deploy these stacks in the following order to ensure networks and dependencies are ready.

### 1. Proxy Stack
*This stack creates the shared `homelab` network and handles HTTPS termination.*

- **Name:** `proxy`
- **Repository URL:** `https://github.com/dave6892/homelab-docker`
- **Compose path:** `docker-compose.yml`
- **Environment Variables:** None needed.

### 2. DNS Stack
*Provides local DNS resolution.*

- **Name:** `dns`
- **Repository URL:** `https://github.com/dave6892/homelab-docker`
- **Compose path:** `app/pihole/docker-compose.yml`
- **Environment Variables:**
  - `WEBPASSWORD`: (Set your desired Pi-hole admin password)
  - `SERVER_IP`: (Your Proxmox Server LAN IP, e.g., `192.168.1.50`)

### 3. App Stacks
*The actual applications.*

#### Homepage
- **Name:** `homepage`
- **Repository URL:** `https://github.com/dave6892/homelab-docker`
- **Compose path:** `app/homepage/docker-compose.yml`
- **Environment Variables:**
  - `PLEX_SERVER_URL`: `http://plex.local`
  - `TAUTULLI_SERVER_URL`: `http://tautulli.local`

#### Media
- **Name:** `media`
- **Repository URL:** `https://github.com/dave6892/homelab-docker`
- **Compose path:** `app/media/docker-compose.yml`
- **Environment Variables:**
  - `NFS_VOLUME_PATH`: (Path to your media on the server, e.g., `/mnt/data/media`)

## Post-Deployment Configuration

### 1. Configure Pi-hole DNS Records
1.  Go to `http://<SERVER_IP>:8080` (Traefik) to verify routing, or `http://<SERVER_IP>/admin` (if Pi-hole port 80 is exposed directly, but we are using Traefik).
2.  Actually, access Pi-hole via: `http://pihole.local` (You might need to map it in your hosts file temporarily or use the server IP).
3.  **Navigate to:** Local DNS -> DNS Records.
4.  **Add Records:**
    -   `homepage.local` -> `<YOUR_SERVER_IP>`
    -   `plex.local` -> `<YOUR_SERVER_IP>`
    -   `tautulli.local` -> `<YOUR_SERVER_IP>`
    -   `pihole.local` -> `<YOUR_SERVER_IP>`

### 2. Update Your Router / Devices
Point your router's DNS settings to `<YOUR_SERVER_IP>` to enable ad-blocking and local domain resolution for your entire network.

## Troubleshooting

### Port 53 Conflict (Pi-hole)
If Portainer says "port 53 is already used", something on your host is listening on that port.

**Step 1: Identify the culprit**
Run this command on your Proxmox server:
```bash
sudo ss -tulpn | grep :53
# OR
sudo lsof -i :53
```

**Step 2: Common Fixes**

**Scenario A: `systemd-resolved` (Ubuntu/Standard Debian)**
1.  Edit `/etc/systemd/resolved.conf` and set `DNSStubListener=no`.
2.  Restart: `sudo systemctl restart systemd-resolved`.

**Scenario B: `dnsmasq` (Libvirt/LXC)**
If `dnsmasq` is running, it might be used by Proxmox for LXC containers.
-   **Fix:** You might need to bind Pi-hole to a specific IP (e.g., your LAN IP) instead of `0.0.0.0`.
-   **Edit `app/pihole/docker-compose.yml`**:
    ```yaml
    ports:
      - "192.168.1.50:53:53/tcp"  # Replace with your Server IP
      - "192.168.1.50:53:53/udp"
    ```