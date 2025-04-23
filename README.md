# Lemvotes

This is an app to get information about who voted on a Lemmy post. It gets the information from an admin account on an instance. It uses only publicly accessible information (anyone could spin up an instance and get the vote counts).

The backend is written in Python and the frontend in SvelteKit.

## Self-hosting

We'll need Docker and Docker Compose, you can follow Docker's [official guide](https://docs.docker.com/engine/install/) for your preferred platform (I only have support for Linux AMD64 and ARM64 in my Docker images because adding more would be yet another platform GitHub Actions has to build for). If you'd like to run this on any other platform you can build the docker image yourself by cloning this repo and using the following compose file:

```yaml
services:
  frontend:
    build:
      context: ./frontend
      dockerfile: Dockerfile
    depends_on:
      - backend
    labels:
      - traefik.enable=true
      - traefik.http.routers.http-votes.entryPoints=http
      - traefik.http.routers.http-votes.rule=Host(`votes.gregtech.eu`)
      - traefik.http.middlewares.https_redirect.redirectscheme.scheme=https
      - traefik.http.middlewares.https_redirect.redirectscheme.permanent=true
      - traefik.http.routers.http-votes.middlewares=https_redirect
      - traefik.http.routers.https-votes.entryPoints=https
      - traefik.http.routers.https-votes.rule=Host(`votes.gregtech.eu`)
      - traefik.http.routers.https-votes.service=votes
      - traefik.http.routers.https-votes.tls=true
      - traefik.http.services.votes.loadbalancer.server.port=3000
      - traefik.http.routers.https-votes.tls.certResolver=le-ssl
    environment:
      - PUBLIC_BACKEND_URL=https://api.gregtech.eu
      - PUBLIC_INSTANCE_URL=gregtech.eu

        

  backend:
    build:
      context: ./backend
      dockerfile: Dockerfile
    labels:
      - traefik.enable=true
      - traefik.http.routers.http-votes-api.entryPoints=http
      - traefik.http.routers.http-votes-api.rule=Host(`api.gregtech.eu`)
      - traefik.http.middlewares.https_redirect.redirectscheme.scheme=https
      - traefik.http.middlewares.https_redirect.redirectscheme.permanent=true
      - traefik.http.routers.http-votes-api.middlewares=https_redirect
      - traefik.http.routers.https-votes-api.entryPoints=https
      - traefik.http.routers.https-votes-api.rule=Host(`api.gregtech.eu`)
      - traefik.http.routers.https-votes-api.service=votes-api
      - traefik.http.routers.https-votes-api.tls=true
      - traefik.http.services.votes-api.loadbalancer.server.port=8000
      - traefik.http.routers.https-votes-api.tls.certResolver=le-ssl
    environment:
      - LEMMY_USERNAME=redacted
      - LEMMY_PASSWORD=redacted
      - LEMMY_INSTANCE=https://gregtech.eu
      - FRONTEND_URL=https://votes.gregtech.eu

networks:
  default:
    name: traefik_access
    external: true
```

### Domains

You will need two domains/subdomains for Lemvotes, I have `api.gregtech.eu` for the API and `votes.gregtech.eu` for the frontend, however you can customize these as you wish.

### Traefik

I use Traefik as my reverse proxy, so I will use it in this guide. Create a new folder on your server named `traefik` (or anything else, doesn't really matter), then make a file named `docker-compose.yml

You can use the following docker compose file to host it with Traefik on Traefik's external network named `traefik_access`:

```yaml
services:

  traefik:
    image: traefik:latest
    ports:
      - 80:80
      - 443:443
      - 8080:8080
    environment: #for cloudflare, you can remove the environment block if you don't use cloudflare
      - CF_DNS_API_TOKEN=redacted
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
      - ./traefik.yml:/etc/traefik/traefik.yml #the config for traefik
      - ./acme.json:/acme.json #certificate store
      - ./routes/:/routes #dynamic routes
    dns:
      - 1.1.1.1
      - 8.8.8.8
    restart: always
networks:
  default:
    name: traefik_access
```

and then paste the following into `traefik.yml`:

```yaml
certificatesResolvers:
  letencrypt:
    acme:
      email: youremail@email.com
      storage: /certs/acme.json
      caServer: https://acme-v02.api.letsencrypt.org/directory # prod (default)
      #caServer: https://acme-staging-v02.api.letsencrypt.org/directory # staging
      httpChallenge:
        entryPoint: web

providers:
  docker:
    exposedByDefault: false
    network: traefik_access

log:
  level: DEBUG
accessLog: {}

api:
  dashboard: false
  insecure: false

```

once done, run `docker compose up -d` to start Traefik.

### Setting up the server itself

This part is relatively simple, just create a new directory (not in the `traefik` directory of course) and paste this into `docker-compose.yml`:

```yaml
services:
  frontend:
    image: ghcr.io/gragorther/votes-frontend:main
    depends_on:
      - backend
    labels:
      - traefik.enable=true
      - traefik.http.routers.http-votes.entryPoints=http
      - traefik.http.routers.http-votes.rule=Host(`votes.gregtech.eu`)
      - traefik.http.middlewares.https_redirect.redirectscheme.scheme=https
      - traefik.http.middlewares.https_redirect.redirectscheme.permanent=true
      - traefik.http.routers.http-votes.middlewares=https_redirect
      - traefik.http.routers.https-votes.entryPoints=https
      - traefik.http.routers.https-votes.rule=Host(`votes.gregtech.eu`)
      - traefik.http.routers.https-votes.service=votes
      - traefik.http.routers.https-votes.tls=true
      - traefik.http.services.votes.loadbalancer.server.port=3000
      - traefik.http.routers.https-votes.tls.certResolver=le-ssl
    environment:
      - PUBLIC_BACKEND_URL=https://api.gregtech.eu
      - PUBLIC_INSTANCE_DOMAIN=gregtech.eu

        

  backend:
    image: ghcr.io/gragorther/votes-backend:main
    labels:
      - traefik.enable=true
      - traefik.http.routers.http-votes-api.entryPoints=http
      - traefik.http.routers.http-votes-api.rule=Host(`api.gregtech.eu`)
      - traefik.http.middlewares.https_redirect.redirectscheme.scheme=https
      - traefik.http.middlewares.https_redirect.redirectscheme.permanent=true
      - traefik.http.routers.http-votes-api.middlewares=https_redirect
      - traefik.http.routers.https-votes-api.entryPoints=https
      - traefik.http.routers.https-votes-api.rule=Host(`api.gregtech.eu`)
      - traefik.http.routers.https-votes-api.service=votes-api
      - traefik.http.routers.https-votes-api.tls=true
      - traefik.http.services.votes-api.loadbalancer.server.port=8000
      - traefik.http.routers.https-votes-api.tls.certResolver=le-ssl
    environment:
      - LEMMY_USERNAME=redacted
      - LEMMY_PASSWORD=redacted
      - LEMMY_INSTANCE=https://gregtech.eu
      - FRONTEND_URL=https://votes.gregtech.eu

networks:
  default:
    name: traefik_access
    external: true
```

make sure to modify the URLs to fit your setup, then run `docker compose up -d` to start Lemvotes and it should be accessible on the domain you set for the frontend (`votes.gregtech.eu` in my case).
