# Practice Guide — what to run on your own laptop

These sheets split into: (A) files — all done for you in this repo,
and (B) hands-on experiments that need Docker Desktop / kind running
on YOUR laptop, because they teach by watching things happen live.

## Docker sheet
```bash
docker build -t todo-practice .
docker images

# Run alone - the page loads, adding a to-do fails with
# "MongoDB connection error: connect ECONNREFUSED" (expected, §6)
docker run -p 5000:5000 --name todo-solo todo-practice
docker rm todo-solo        # after Ctrl+C

# Everyday commands (with todo-solo running)
docker ps ; docker ps -a ; docker logs todo-solo ; docker logs -f todo-solo
docker exec -it todo-solo sh        # then: ls, cat package.json
docker stats ; docker top todo-solo ; docker inspect todo-solo
docker inspect -f '{{.NetworkSettings.IPAddress}}' todo-solo
docker port todo-solo
docker cp todo-solo:/app/package.json ./copied-package.json
docker diff todo-solo ; docker history todo-practice
docker network ls ; docker network inspect bridge
docker volume ls ; docker system df
docker build --no-cache -t todo-practice .
docker save -o todo-practice.tar todo-practice ; docker load -i todo-practice.tar

# App + database together
docker compose up            # http://localhost:5000 - add 3 to-dos
docker compose down          # data survives (named volume)
docker compose up            # to-dos still there
docker compose down -v       # volume deleted
docker compose up            # list is empty - that is the lesson
```

## CI sheet (this repo IS that practice repo)
- `.github/workflows/docker-ci.yml` runs on every push to main:
  builds the image, runs `npm test` INSIDE the container, tags the
  image with the commit SHA, logs in to GHCR with GITHUB_TOKEN
  (no personal token) and pushes both the SHA tag and `latest`.
- Task 5 (break it on purpose) is built into this repo's history:
  one commit deliberately changed a test expectation to `false`
  (red run), the next commit fixed it back (green run). Check the
  Actions tab to see both.

## Kubernetes sheet
```bash
brew install kind kubectl            # Mac (Windows: choco install kind kubernetes-cli)
kind create cluster --name todo-practice
kubectl cluster-info ; kubectl get nodes      # 1 node, Ready
kubectl get pods -n kube-system               # K8s runs on K8s

# Bare pod (no self-healing)
kubectl run todo-test --image=ghcr.io/chandramohanm069-debug/todo-practice:latest --port=5000
kubectl get pods ; kubectl logs todo-test ; kubectl delete pod todo-test

# Real workload (note: GHCR package must be Public for kind to pull it)
kubectl apply -f k8s-practice/
kubectl get pods ; kubectl get svc ; kubectl get deployments
kubectl port-forward svc/todo-service 5000:5000   # http://localhost:5000

# Watch it heal / scale / update (keep `kubectl get pods -w` open)
kubectl delete pod <one-todo-pod>             # a replacement appears by itself
kubectl scale deployment todo-deployment --replicas=4
kubectl set image deployment/todo-deployment todo=ghcr.io/chandramohanm069-debug/todo-practice:v2
kubectl rollout status deployment/todo-deployment
kubectl rollout history deployment/todo-deployment
kubectl rollout undo deployment/todo-deployment

kubectl delete -f k8s-practice/
kind delete cluster --name todo-practice
```

## Self-check status
- [x] App code, Dockerfile, .dockerignore, docker-compose.yml written
- [x] utils.js + test.js written, `npm test` passes locally
- [x] docker-ci.yml: builds image, tests in container, SHA tag, GHCR push
- [x] One deliberately red CI run followed by a green fixing run (repo history)
- [x] k8s-practice/: Mongo Deployment+Service, To-Do Deployment (2 replicas) + NodePort Service
- [x] Docker Scenarios: all 12 answered in docs/docker-scenarios-answers.md
- [ ] On your laptop: docker build/run/compose experiments above (need Docker Desktop)
- [ ] On your laptop: kind cluster experiments above (self-healing, scaling, rollout)
