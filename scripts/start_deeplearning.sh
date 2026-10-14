#!/usr/bin/env zsh
# ─────────────────────────────────────────────────────────────────────
# start_deeplearning.sh — One command to spin up the AML lab environment
#
# Usage:
#   ./scripts/start_deeplearning.sh          → start everything
#   ./scripts/start_deeplearning.sh --stop   → stop everything
#   ./scripts/start_deeplearning.sh --logs   → follow logs
# ─────────────────────────────────────────────────────────────────────

DOCKER_BIN="/Applications/Docker.app/Contents/Resources/bin/docker"
DOCKER_BACKEND="/Applications/Docker.app/Contents/MacOS/com.docker.backend"
SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"

# ── Helpers ────────────────────────────────────────────────────────
daemon_running() {
  pgrep -f "com.docker.backend" > /dev/null 2>&1 && \
  "$DOCKER_BIN" info > /dev/null 2>&1
}

start_daemon() {
  if daemon_running; then
    echo "✅ Docker daemon already running."
    return
  fi
  echo "🚀 Starting Docker daemon (headless)..."
  nohup "$DOCKER_BACKEND" -with-frontend=false > /tmp/docker-backend.log 2>&1 &
  disown
  local tries=0
  until daemon_running || [ $tries -ge 40 ]; do
    printf "."; sleep 1; tries=$((tries+1))
  done
  echo ""
  if daemon_running; then
    echo "✅ Docker is ready!"
  else
    echo "❌ Docker failed to start. Check: /tmp/docker-backend.log"
    exit 1
  fi
}

# ── Handle flags ───────────────────────────────────────────────────
case "${1:-}" in
  --stop)
    echo "🛑 Stopping AML containers..."
    cd "$SCRIPT_DIR" && "$DOCKER_BIN" compose down
    echo "✅ Done."
    exit 0
    ;;
  --logs)
    cd "$SCRIPT_DIR" && "$DOCKER_BIN" compose logs -f
    exit 0
    ;;
esac

# ── Main: start daemon + container ────────────────────────────────
start_daemon
echo ""
echo "📦 Starting AML deep learning container..."
cd "$SCRIPT_DIR" && "$DOCKER_BIN" compose up -d --build

echo ""
echo "──────────────────────────────────────────────"
echo "  ✅ Jupyter Lab is running!"
echo "  🔗 Open → http://localhost:8888"
echo "  📂 Your notebooks are at /workspace inside the container"
echo "  🛑 To stop: ./scripts/start_deeplearning.sh --stop"
echo "──────────────────────────────────────────────"
