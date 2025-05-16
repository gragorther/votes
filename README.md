# Lemvotes

This is an app to get information about who voted on a Lemmy post. It gets the information from an admin account on an instance. It uses only publicly accessible information (anyone could spin up an instance and get the vote counts).

The entire app is written in SvelteKit.

## Development

I use [pnpm](https://pnpm.io/) as the package manager for Lemvotes. Run `pnpm i` to install the dependencies, `pnpm update` to update them if necessary and `pnpm dev` to start the dev server. For development you would also need a Lemmy database to test with, which I will not provide a download to for security reasons. You can spin up your own dev Lemmy instance.

## Self-hosting

We'll need Docker and Docker Compose, you can follow Docker's official guide for your preferred platform (I only have support for Linux AMD64 and ARM64 in my Docker images because adding more would be yet another platform GitHub Actions has to build for, which takes a while). If you'd like to run this on any other platform you can build the docker image yourself by cloning this repo and using the following compose file:

```yaml
services:
  lemvotes:
    image: ghcr.io/gragorther/lemvotes:main
    restart: unless-stopped
    logging:
      driver: local
    labels:
      - traefik.enable=true
      - traefik.http.routers.http-votes.entryPoints=http
      - traefik.http.routers.http-votes.rule=Host(`lemvotes.org`)
      - traefik.http.middlewares.https_redirect.redirectscheme.scheme=https
      - traefik.http.middlewares.https_redirect.redirectscheme.permanent=true
      - traefik.http.routers.http-votes.middlewares=https_redirect
      - traefik.http.routers.https-votes.entryPoints=https
      - traefik.http.routers.https-votes.rule=Host(`lemvotes.org`)
      - traefik.http.routers.https-votes.service=votes
      - traefik.http.routers.https-votes.tls=true
      - traefik.http.services.votes.loadbalancer.server.port=3000
      - traefik.http.routers.https-votes.tls.certResolver=le-ssl
    environment:
       - DATABASE_URL=postgresql://user:password@postgres:5432/lemmy?connect_timeout=3000 #make sure to set your own credentials
    networks:
      - database
      - default

networks:
  default:
    name: traefik_access
    external: true
  database:

```

Make sure to set your own credentials in the `DATABASE_URL` env var and set your own domain in the Traefik labels. You will also need a working Traefik setup. If you don't use Traefik, use your reverse proxy's respective configuration and remove the labels from this compose file.
