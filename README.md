# To-Do CI Practice

A tiny To-Do List app (Express + MongoDB + one plain HTML page) built
to practice Docker, CI and Kubernetes — following the Docker,
CI+Docker, Docker Scenarios and Kubernetes practice sheets.

## Run it
```bash
# Everything (app + MongoDB):
docker compose up
# http://localhost:5000

# Tests (no MongoDB or server needed):
npm test
```

## What's in here
| File | Sheet |
|---|---|
| `server.js`, `public/index.html`, `package.json` | Docker — the app |
| `Dockerfile`, `.dockerignore` | Docker — image recipe |
| `docker-compose.yml` | Docker — app + db, `mongo-data` volume |
| `utils.js`, `test.js` | CI — tiny test for the pipeline to run |
| `.github/workflows/docker-ci.yml` | CI — build image, test inside container, tag with commit SHA, push to GHCR with `GITHUB_TOKEN` |
| `k8s-practice/mongo-deployment.yaml` | Kubernetes — Mongo Deployment + ClusterIP Service |
| `k8s-practice/todo-deployment.yaml` | Kubernetes — To-Do Deployment (2 replicas) + NodePort Service (30080) |
| `docs/docker-scenarios-answers.md` | Scenarios — all 12 scenarios answered |
| `docs/practice-guide.md` | Hands-on commands for Docker Desktop / kind on your laptop |

## Docker image
`ghcr.io/chandramohanm069-debug/todo-practice:latest`
(plus a per-commit SHA tag, pushed automatically by CI on every push to main)

## Kubernetes
```bash
kubectl apply -f k8s-practice/
kubectl get pods,svc
kubectl port-forward svc/todo-service 5000:5000
```
Note: the GHCR package must be Public for a local kind cluster to
pull it (GitHub > Packages > todo-practice > Settings > Visibility).
