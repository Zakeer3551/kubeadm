#!/usr/bin/env bash
set -e

echo "===== Phase 2: Container Runtime (containerd) ====="

# Must be run as root
if [[ $EUID -ne 0 ]]; then
  echo "❌ Please run as root or with sudo"
  exit 1
fi

echo "[1/6] Installing containerd dependencies..."
apt-get update -y
apt-get install -y ca-certificates curl gnupg lsb-release

echo "[2/6] Installing containerd..."
apt-get install -y containerd

echo "[3/6] Generating default containerd config..."
mkdir -p /etc/containerd
containerd config default > /etc/containerd/config.toml

echo "[4/6] Configuring containerd to use systemd cgroups..."
sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml

echo "[5/6] Restarting and enabling containerd..."
systemctl daemon-reexec
systemctl enable containerd
systemctl restart containerd

echo "[6/6] Verifying containerd status..."
systemctl --no-pager status containerd | grep -E "Active:|Loaded:"

echo
echo "containerd version:"
containerd --version || echo "⚠️ containerd binary not found"

echo
echo "CRI socket check:"
if [[ -S /run/containerd/containerd.sock ]]; then
  echo "✅ CRI socket exists: /run/containerd/containerd.sock"
else
  echo "❌ CRI socket missing"
  exit 1
fi

echo
echo "===== Phase 2 COMPLETE: Container Runtime Ready ====="
