# 🐳 Docker — Leonida's Field Guide

> **Your daily reference for working with Docker across all projects.** No Docker app needed — everything runs from the terminal.

---

## ⚡ Quick Start (Every Session)

```bash
# 1. Start Docker (headless — no GUI window)
docker-start

# 2. Check it's alive
docker-status

# 3. Go to your project and launch containers
cd ~/Documents/code/AML_Book-Data
dcu         # short for: docker compose up -d

# 4. When done for the day
dcd         # short for: docker compose down
docker-stop # optional: shut down the daemon too
```

---

## 🗺️ Mental Map — How Docker Works

```
Your Mac (Host)
│
├── Docker Daemon (engine — runs in background, no GUI)
│   └── started with: docker-start
│
└── Containers (isolated mini-computers)
    ├── aml-deeplearning  ← Lab 06 & 07 (TF/Keras + Jupyter)
    ├── qdrant            ← Vector DB (research-intelligence)
    ├── n8n               ← AI workflow builder (research-intelligence)
    └── ...your future containers
```

**Key idea**: A container is like a **self-contained computer** inside your Mac. It has its own Python, its own packages, its own file system — but it can see files you share with it (via volumes).

---

## 🔧 Your Shell Aliases Reference

| Alias / Command | What it does |
|---|---|
| `docker-start` | Boot Docker daemon (headless, no app) |
| `docker-stop` | Shut down the daemon |
| `docker-status` | See running containers + image count |
| `dcu` | `docker compose up -d` (start project containers) |
| `dcd` | `docker compose down` (stop project containers) |
| `dcl` | `docker compose logs -f` (follow live logs) |
| `dps` | Pretty-printed container list with ports |
| `docker-ctl.sh start/stop/status/ps/clean/nuke` | Universal daemon controller |

---

## 📁 Your Projects & Their Docker Setup

### 1. AML Book — Deep Learning Labs (Lab 06 & 07)

**Location**: `~/Documents/code/AML_Book-Data/`

```bash
cd ~/Documents/code/AML_Book-Data

# Option A: one-command launcher (recommended)
./scripts/start_deeplearning.sh

# Option B: manual
docker-start
docker compose up -d

# Open Jupyter
open http://localhost:8888

# Stop
docker compose down
```

**What's inside the container**:
- TensorFlow 2.16 + Keras
- scikit-learn, matplotlib, seaborn, pandas, numpy
- Jupyter Lab (port 8888)
- Your notebooks are mounted at `/workspace` — edit in IDE, run in Jupyter

---

### 2. Personal Research Intelligence

**Location**: `~/Documents/code/personal-research-intelligence/`

```bash
cd ~/Documents/code/personal-research-intelligence

# Copy env file and fill in API keys (first time only)
cp .env.example .env
nano .env   # add ANTHROPIC_API_KEY, OPENAI_API_KEY, etc.

# Start services (Qdrant + n8n)
docker-start
docker compose up -d

# Services:
open http://localhost:5678   # n8n visual workflow builder
# Qdrant REST API: http://localhost:6333
# Qdrant gRPC:     http://localhost:6334

# Stop
docker compose down
```

**n8n is your visual AI pipeline builder**:
- Drag & drop nodes for arXiv, LLM calls, Qdrant, Telegram
- No coding needed for Phase 1
- Think of it as a visual version of your Python code

---

## 🧠 Core Docker Concepts (Learn These First)

### Image vs Container

| Term | Analogy | Reality |
|---|---|---|
| **Image** | Recipe / blueprint | Read-only template with all software baked in |
| **Container** | Cooked meal / running app | Live instance of an image |
| **Volume** | Shared folder | Connects your Mac files into a container |
| **Port mapping** | Door into the container | `8888:8888` = Mac port 8888 → Container port 8888 |

```bash
# Pull an image from Docker Hub
docker pull python:3.11-slim

# Run a container from it
docker run python:3.11-slim python --version

# List images on your machine
docker images

# List running containers
docker ps

# List ALL containers (including stopped ones)
docker ps -a
```

---

### The `docker compose` Workflow

For multi-container projects, you use a `docker-compose.yml` file:

```yaml
# Example structure of docker-compose.yml
services:
  my-api:               # name of this container
    build: .            # build from local Dockerfile
    ports:
      - "8000:8000"     # host:container
    volumes:
      - .:/app          # mount current dir to /app
    environment:
      - API_KEY=abc123

  my-db:
    image: postgres:15  # use pre-built image from Docker Hub
    volumes:
      - db_data:/var/lib/postgresql/data

volumes:
  db_data:              # named volume (persists data)
```

**Essential compose commands**:
```bash
docker compose up -d        # start all services in background
docker compose down         # stop all services
docker compose down -v      # stop + DELETE volumes (lose data!)
docker compose logs -f      # follow all logs
docker compose logs -f n8n  # follow logs for one service
docker compose ps           # status of services
docker compose restart n8n  # restart one service
docker compose exec n8n sh  # get a shell inside a container
docker compose build        # rebuild images (after Dockerfile change)
docker compose pull         # update images to latest
```

---

### Getting a Shell Inside a Container

```bash
# Run bash/sh in a running container
docker exec -it aml-deeplearning bash
docker exec -it <container-name> sh

# Check Python version inside
docker exec aml-deeplearning python --version

# Install something temporarily (won't survive container restart)
docker exec -it aml-deeplearning pip install some-package
# To make it permanent → add to Dockerfile, then rebuild
```

---

### Volumes — Keeping Your Data Safe

```bash
# Named volumes (survive container removal)
docker volume ls
docker volume inspect qdrant_data

# Bind mounts (your local folder inside container)
# Example in docker-compose.yml:
#   volumes:
#     - ./notebooks:/workspace    ← local path : container path

# Remove all unused volumes (careful — data loss!)
docker volume prune
```

---

## 🔁 Daily Workflow Patterns

### Starting a Work Session

```bash
# 1. Start Docker daemon
docker-start

# 2. Navigate to your project
cd ~/Documents/code/AML_Book-Data    # or research-intelligence

# 3. Start containers
dcu

# 4. Check they're running
dps
```

### Stopping for the Day

```bash
# Stop project containers (data in volumes is preserved)
dcd

# Optional: shut down Docker daemon to save RAM/CPU
docker-stop
```

### After Changing a Dockerfile

```bash
# Rebuild the image and restart the container
docker compose up -d --build
```

### Debugging a Failing Container

```bash
# See what went wrong
dcl                              # follow logs
docker compose logs --tail=50    # last 50 lines

# Get a shell inside even if it crashed
docker run -it --entrypoint sh <image-name>

# Inspect container details
docker inspect <container-name>
```

---

## 🌐 FastAPI in Docker (Future Projects)

When you build APIs, here's the standard pattern:

```dockerfile
# Dockerfile for a FastAPI service
FROM python:3.11-slim

WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

EXPOSE 8000
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000", "--reload"]
```

```yaml
# docker-compose.yml
services:
  api:
    build: .
    ports:
      - "8000:8000"
    volumes:
      - .:/app          # live reload — code changes apply instantly
    environment:
      - DATABASE_URL=postgresql://user:pass@db:5432/mydb
    depends_on:
      - db

  db:
    image: postgres:15
    environment:
      - POSTGRES_PASSWORD=pass
      - POSTGRES_USER=user
      - POSTGRES_DB=mydb
    volumes:
      - postgres_data:/var/lib/postgresql/data

volumes:
  postgres_data:
```

```bash
# Start everything
dcu

# Test your API
curl http://localhost:8000/docs    # Swagger UI
open http://localhost:8000/docs    # in browser
```

---

## 🤖 n8n + Agentic AI Patterns

**n8n** is your visual no-code AI pipeline builder. Think of each node as a Python function you'd write, but visual.

### Useful n8n Docker Tips

```bash
cd ~/Documents/code/personal-research-intelligence

# Start n8n
docker compose up -d n8n
open http://localhost:5678

# See n8n logs
docker compose logs -f n8n

# Back up n8n workflows
docker cp n8n-container:/home/node/.n8n ./n8n-backup

# Update n8n to latest version
# 1. Edit docker-compose.yml → change image tag to newer version
# 2. docker compose pull n8n
# 3. docker compose up -d n8n
```

### Typical Agentic AI Stack in Docker

```yaml
services:
  # n8n — visual orchestration
  n8n:
    image: docker.n8n.io/n8nio/n8n

  # Qdrant — vector database for RAG
  qdrant:
    image: qdrant/qdrant

  # Ollama — local LLMs (optional)
  ollama:
    image: ollama/ollama
    ports:
      - "11434:11434"

  # FastAPI — your custom agent API
  agent-api:
    build: ./phase-03-agent
    ports:
      - "8000:8000"
```

---

## 🛠️ Maintenance Commands

```bash
# Remove stopped containers + unused images (safe)
docker-ctl.sh clean

# See how much disk Docker is using
docker system df

# Remove everything (NUCLEAR — lose all images/containers/volumes)
docker-ctl.sh nuke

# Remove specific image
docker rmi tensorflow/tensorflow:2.16.1-jupyter

# Remove specific container
docker rm aml-deeplearning

# Force remove running container
docker rm -f aml-deeplearning
```

---

## 🔐 Environment Variables & Secrets

**Golden rule**: Never hardcode API keys. Use `.env` files.

```bash
# .env file (never commit to git)
OPENAI_API_KEY=sk-...
ANTHROPIC_API_KEY=...
DATABASE_URL=postgresql://...

# docker-compose.yml reads .env automatically
services:
  my-app:
    environment:
      - OPENAI_API_KEY=${OPENAI_API_KEY}
```

```bash
# Check your .gitignore includes:
echo ".env" >> .gitignore
```

---

## 📊 Port Reference — Your Projects

| Port | Service | Project |
|---|---|---|
| `8888` | Jupyter Lab (TF) | AML Book (lab06/07) |
| `5678` | n8n UI | research-intelligence |
| `6333` | Qdrant REST | research-intelligence |
| `6334` | Qdrant gRPC | research-intelligence |
| `8000` | FastAPI (future) | Any Python API project |
| `11434` | Ollama (future) | Local LLM inference |
| `5432` | PostgreSQL (future) | Any DB-backed project |

---

## 🚨 Troubleshooting

### "Cannot connect to Docker daemon"
```bash
docker-start    # just run this
docker info     # verify it worked
```

### Container won't start
```bash
docker compose logs    # check error message
docker compose down && docker compose up -d    # restart clean
```

### Port already in use
```bash
lsof -i :8888    # find what's using port 8888
kill -9 <PID>    # kill it
dcu              # try again
```

### Jupyter not accessible at localhost:8888
```bash
# Check the container is running
dps

# Check logs for the Jupyter URL
dcl

# Try restarting
docker compose restart jupyter-tf
```

### Out of disk space
```bash
docker system df         # see usage
docker-ctl.sh clean      # remove stopped containers + dangling images
```

---

## 🚀 To Use Right Now (Open a New Terminal Tab)

```bash
# Activate the new shell setup (once per old terminal)
source ~/.zshrc

# Start Docker (no app needed!)
docker-start

# Run your AML labs
cd ~/Documents/code/AML_Book-Data
./scripts/start_deeplearning.sh

# Then open http://localhost:8888
```

> [!NOTE]
> The first `docker compose up` will pull the TensorFlow image (~2GB) — this is a one-time download. After that it starts in seconds.

---

## 📚 What to Learn Next (In Order)

1. **Docker basics** — you're here ✅
2. **Writing Dockerfiles** — customize environments
3. **docker compose** — multi-service projects
4. **FastAPI** — building REST APIs in Python
5. **Networking** — containers talking to each other
6. **Docker volumes** — persistent data management
7. **Docker Hub** — sharing your images
8. **GitHub Actions + Docker** — CI/CD pipelines

---

*Updated: September 2026 | Leonida's personal Docker reference*
