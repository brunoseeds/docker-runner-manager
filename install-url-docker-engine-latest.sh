#!/usr/bin/env bash
# Install/upgrade to the latest Docker Engine (>=27), Buildx, and Compose v2 on Ubuntu
# Safe for docker-machine provisioning via engine-install-url.
# Works on Ubuntu 20.04/22.04/24.04.
set -euo pipefail

export DEBIAN_FRONTEND=noninteractive

echo "[1/6] Removing any old Docker bits..."
# Remove legacy packages if present (ignore errors)
apt-get remove -y docker docker-engine docker.io containerd runc || true
apt-get purge  -y docker docker-engine docker.io containerd runc || true
apt-get update -y

echo "[2/6] Installing prerequisites..."
apt-get install -y ca-certificates curl gnupg lsb-release

echo "[3/6] Adding Docker’s official apt repo..."
install -d -m 0755 /etc/apt/keyrings
if [ ! -f /etc/apt/keyrings/docker.gpg ]; then
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
  chmod a+r /etc/apt/keyrings/docker.gpg
fi

# Determine codename (focal/jammy/noble...)
. /etc/os-release
ARCH="$(dpkg --print-architecture)"
CODENAME="${VERSION_CODENAME:-$(lsb_release -cs)}"

cat >/etc/apt/sources.list.d/docker.list <<EOF
deb [arch=${ARCH} signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu ${CODENAME} stable
EOF

apt-get update -y

echo "[4/6] Installing latest Docker Engine + CLI + containerd + Buildx + Compose v2..."
# If you need a specific version, you can pin with e.g. docker-ce=5:27.3.1-1~ubuntu.${CODENAME} etc.
apt-get install -y \
  docker-ce \
  docker-ce-cli \
  containerd.io \
  docker-buildx-plugin \
  docker-compose-plugin

echo "[5/6] Enabling and starting Docker..."
systemctl enable docker
systemctl restart docker

# Optional: minimal daemon defaults (safe/log-friendly). Create if absent; don't overwrite custom configs.
if [ ! -f /etc/docker/daemon.json ]; then
  cat >/etc/docker/daemon.json <<'JSON'
{
  "log-driver": "json-file",
  "log-opts": { "max-size": "10m", "max-file": "3" },
  "features": { "buildkit": true }
}
JSON
  systemctl restart docker
fi

echo "[6/6] Verifying installation..."
docker --version || (echo "Docker CLI not found in PATH"; exit 1)
docker version || true   # may fail if daemon still coming up; not fatal
docker buildx version || true
docker compose version || true

echo "✔ Docker installation complete."
