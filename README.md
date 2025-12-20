# Homelab Docker (GitOps Ready)

A Docker-based homelab setup featuring a dashboard, media server, local DNS, and reverse proxy. Designed to be deployed via **Portainer Stacks** (GitOps).

## Architecture

- **Traefik**: Reverse proxy and load balancer (Port 80/443).
- **Pi-hole**: Local DNS and Ad-blocking (Port 53).
- **Apps**: Homepage, Plex, Tautulli (Internal ports only).

## Deployment via Portainer

Deploy these stacks in the following order to ensure networks and dependencies are ready.

### 1. Proxy Stack
*This stack creates the shared `homelab` network.*

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

### 3. App Stacks
*The actual applications.*

#### Homepage
- **Name:** `homepage`
- **Repository URL:** `https://github.com/dave6892/homelab-docker`
- **Compose path:** `app/homepage/docker-compose.yml`
- **Environment Variables:**
  - `PLEX_SERVER_URL`: `http://plex.home`
  - `TAUTULLI_SERVER_URL`: `http://tautulli.home`

#### Media
- **Name:** `media`
- **Repository URL:** `https://github.com/dave6892/homelab-docker`
- **Compose path:** `app/media/docker-compose.yml`
- **Environment Variables:**
  - `NFS_VOLUME_PATH`: (Path to your media on the server, e.g., `/mnt/data/media`)

## Post-Deployment Configuration

### 1. Configure Pi-hole DNS Records
1.  Go to `http://<SERVER_IP>:8080` (Traefik) to verify routing, or `http://<SERVER_IP>/admin` (if Pi-hole port 80 is exposed directly, but we are using Traefik).
2.  Actually, access Pi-hole via: `http://pihole.home` (You might need to map it in your hosts file temporarily or use the server IP).
3.  **Navigate to:** Local DNS -> DNS Records.
4.  **Add Records:**
    -   `homepage.home` -> `<YOUR_SERVER_IP>`
    -   `plex.home` -> `<YOUR_SERVER_IP>`
    -   `tautulli.home` -> `<YOUR_SERVER_IP>`
    -   `pihole.home` -> `<YOUR_SERVER_IP>`

### 2. Update Your Router / Devices
Point your router's DNS settings to `<YOUR_SERVER_IP>` to enable ad-blocking and local domain resolution for your entire network.