# Homelab Docker

A Docker-based homelab setup featuring a dashboard, media server, and reverse proxy.

## Architecture

This project uses **Traefik** as a reverse proxy to route traffic to various services using local domain names. All services are connected via a dedicated `homelab` Docker network.

### Services

| Service | Internal Port | Local Domain | Description |
|---------|---------------|--------------|-------------|
| **Traefik** | 80, 8080 | `localhost:8080` | Reverse proxy and load balancer |
| **Homepage** | 3000 | `homepage.local` | Main dashboard |
| **Plex** | 32400 | `plex.local` | Media server |
| **Tautulli** | 8181 | `tautulli.local` | Plex monitoring and tracking |

## Getting Started

### Prerequisites
- Docker and Docker Compose installed
- `sudo` access for editing `/etc/hosts`

### Installation

1. **Create the Network**
   ```bash
   docker network create homelab
   ```

2. **Start the Proxy**
   Start Traefik first to handle routing:
   ```bash
   docker-compose up -d
   ```

3. **Start Applications**
   Start the application stacks:
   ```bash
   # Start Homepage
   cd app/homepage
   docker-compose up -d

   # Start Media Stack (Plex, Tautulli)
   cd ../media
   docker-compose up -d
   ```

4. **Configure Local DNS**
   To access services via their `.local` domains, add them to your `/etc/hosts` file:
   ```bash
   echo "127.0.0.1 homepage.local plex.local tautulli.local" | sudo tee -a /etc/hosts
   ```

5. **Access Services**
   - Dashboard: [http://homepage.local](http://homepage.local)
   - Plex: [http://plex.local](http://plex.local)
   - Tautulli: [http://tautulli.local](http://tautulli.local)
   - Traefik Dashboard: [http://localhost:8080](http://localhost:8080)

## Configuration

### Environment Variables
Check `app/homepage/.env` to configure service URLs for the dashboard:
```bash
PLEX_SERVER_URL=http://plex.local
TAUTULLI_SERVER_URL=http://tautulli.local
```