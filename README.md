# votes

This is an app to get information about who voted on a Lemmy post. It gets the information from an admin account on an instance. You can use the following docker compose file to host it with Traefik on Traefik's external network named `traefik_access`:

```yaml
# make sure to change the URLs

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
      - PUBLIC_INSTANCE_URL=gregtech.eu

        

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
