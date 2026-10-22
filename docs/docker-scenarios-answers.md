# Docker Scenarios — Answers (To-Do App)

## Part 1: Images and containers

### 1. The image built, but nothing happens
Forgot `-p 5000:5000`. Building only assembles the image; it decides
nothing about exposure. Without publishing a port, the app runs on
port 5000 inside the container's private network, unreachable from
the browser. Proof: `docker exec -it <name> sh` then
`wget -qO- localhost:5000` works from inside.
Fix: `docker run -p 5000:5000 todo-practice`

### 2. Same Dockerfile, wildly different image sizes (1.2 GB vs 180 MB)
First check `.dockerignore`. Without it, a local `node_modules` folder
is copied in by `COPY . .` on top of the fresh one `RUN npm install`
already created. Check with `docker history todo-practice` (size per
layer) or `du -sh node_modules` inside the container.

### 3. It worked five minutes ago (old code still served after rebuild)
A running container keeps the code it was started with. Rebuilding
the image does not update existing containers.
Fix: `docker stop todo-solo && docker rm todo-solo`, then
`docker run -p 5000:5000 --name todo-solo todo-practice` again.
First diagnostic whenever code changes "don't show up": `docker ps`.

### 4. Build takes 40s even for a one-line HTML change
Layer caching is being invalidated. If `COPY . .` sits before
`RUN npm install`, any file change busts that layer and every layer
after it, forcing a full reinstall. Correct order (as in this repo's
Dockerfile): `COPY package*.json ./` → `RUN npm install` → `COPY . .`

## Part 2: Networking and docker-compose

### 5. Standalone container can't reach the database
`localhost` inside a container means that container itself — not the
laptop, not another container. Two containers are not automatically
networked. Put both on the same custom Docker network and refer to
Mongo by container name, or use docker-compose (which does this).

### 6. Compose works, manual docker run doesn't (same image)
Compose creates a dedicated project network (`<folder>_default`),
attaches every service, and provides DNS by service name — so `db`
resolves to the database container. Plain `docker run` lands on the
default bridge, where containers can reach each other by IP but not
by name. Verify: `docker network ls`, `docker network inspect <folder>_default`.

### 7. "Port is already allocated"
Something (almost always a forgotten earlier container) already
holds host port 5000. Find it with `docker ps` (look for 5000 in the
PORTS column), `docker stop`/`docker rm` it, then `docker compose up`.

### 8. A teammate hardcodes the Mongo URL
Locally, `mongodb://localhost:27017` happened to point at a local
Mongo. Inside the compose app container, localhost = the app
container itself, where no Mongo runs. The `MONGO_URL` environment
variable in docker-compose.yml exists so the same code points at
`localhost` outside Docker and at `db` inside it. Hardcoding removes
that switch and breaks exactly the compose case.

## Part 3: Data and volumes

### 9. All the to-dos disappeared after a routine restart
With the named volume in place this should NOT happen: `docker compose
down` removes containers but leaves named volumes, so data survives
`up`. If data vanished, either `down -v` was used by accident (that
deletes volumes) or the `volumes:` section is missing. Check with
`docker volume ls` after `down` — is `mongo-data` still there?

### 10. Two people, two different experiences with the same file
The one line responsible:
```yaml
volumes:
  - mongo-data:/data/db
```
Without it Mongo writes inside the container's writable layer, which
dies with the container. With it, `/data/db` is redirected to
Docker-managed storage outside any container's lifecycle; it survives
deletion/recreation and is removed only by explicitly deleting the
volume (or `down -v`).

## Part 4: Getting it out into the real world

### 11. Push fails with "unauthorized"
Two realistic causes: (1) the Personal Access Token used for
`docker login ghcr.io` expired — old login sessions don't renew;
generate a new token with `write:packages` and log in again.
(2) A typo in the image tag — it must be exactly
`ghcr.io/<your-username>/todo-practice`, otherwise GitHub can't tell
whose packages you're pushing to and reports an auth failure.
Check the exact tag with `docker images` before blaming the login.

### 12. It works on your machine, breaks for your evaluator
`FROM node:latest` — `latest` is not a version, it's whatever Node
release is tagged latest on the day of the build. Your month-old
local cache kept an older Node, so it kept working for you; a fresh
machine pulls the newer major Node and a dependency breaks.
Fix: pin the base image, e.g. `FROM node:18-alpine` (as this repo
does), so everyone builds on the exact same Node every time.
