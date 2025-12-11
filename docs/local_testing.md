# Local Testing Guide

This guide explains how to test the Homelab Docker stack locally on your development machine (Mac/Linux) before deploying it to your Proxmox server.

## Prerequisites

- Docker Desktop (Mac) or Docker Engine (Linux)
- `docker-compose`
- Sudo access (for editing `/etc/hosts`)

## Testing Strategy

Since we cannot easily run a production DNS server (Pi-hole) on a development machine due to port conflicts (especially port 53 on macOS), we use a **Hybrid Approach**:

1.  **Traefik & Apps**: Run exactly as they would in production.
2.  **DNS**: Simulate Pi-hole's function using your local `/etc/hosts` file.

## Step-by-Step Instructions

### 1. Generate SSL Certificates
First, generate self-signed certificates for HTTPS:

```bash
# From the root of the repo
cd traefik
./generate-certs.sh
cd ..
```

**Install the certificate in your system** to avoid browser warnings:
```bash
# macOS
open traefik/certs/homelab.crt
# In Keychain Access, find the certificate and set it to "Always Trust"
```

### 2. Start the Network & Proxy
Start the Traefik proxy with HTTPS support:

```bash
# Start Traefik (from the root of the repo)
docker-compose up -d
```

### 3. Start the Applications
Start the application stacks you want to test.

```bash
# Start Homepage
docker-compose -f app/homepage/docker-compose.yml up -d

# Start Media Stack (Plex, Tautulli)
docker-compose -f app/media/docker-compose.yml up -d
```

### 4. Simulate DNS Resolution
Since Pi-hole isn't active as your computer's DNS server, you must manually map the domains to your local machine (`127.0.0.1`).

Add the following to your `/etc/hosts` file:

```bash
# Run this command to append the entries
echo "127.0.0.1 homepage.home plex.home tautulli.home pihole.home" | sudo tee -a /etc/hosts
```

### 5. Verify the Setup
Open your browser and test the local domains with HTTPS:

-   **Homepage**: [https://homepage.home](https://homepage.home)
-   **Plex**: [https://plex.home](https://plex.home)
-   **Tautulli**: [https://tautulli.home](https://tautulli.home)
-   **Traefik Dashboard**: [http://localhost:8080](http://localhost:8080)

HTTP URLs will automatically redirect to HTTPS. If you see certificate warnings, ensure you've installed and trusted the certificate in your system.

### 6. Testing Pi-hole (Optional)
Testing Pi-hole locally is tricky because port 53 is often in use by the system.

To test that the Pi-hole *container* works (without using it for actual DNS):

1.  Navigate to the Pi-hole directory: `cd app/pihole`
2.  Run Pi-hole with a custom port mapping to avoid conflicts:
    ```bash
    # Maps container port 53 to host port 5353
    docker-compose run -p 5353:53/tcp -p 5353:53/udp --service-ports -d pihole
    ```
3.  Access the UI at: [https://pihole.home/admin](https://pihole.home/admin)

## Cleanup
When you are done testing, you can stop everything to free up resources.

```bash
# Stop apps
cd app/homepage && docker-compose down
cd ../media && docker-compose down
cd ../pihole && docker-compose down

# Stop proxy
cd ../..
docker-compose down
```

Optionally, remove the entries from your `/etc/hosts` file if you don't want them persisting.
