#!/usr/bin/env bash

set -e

echo "===== Kubernetes Node Preflight Script ====="

echo "[1/6] Loading required kernel modules..."
sudo modprobe overlay || true
sudo modprobe br_netfilter || true

echo "[2/6] Persisting kernel modules..."
sudo tee /etc/modules-load.d/k8s.conf > /dev/null <<EOF
overlay
br_netfilter
EOF

echo "[3/6] Applying sysctl parameters..."
sudo tee /etc/sysctl.d/k8s.conf > /dev/null <<EOF
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

sudo sysctl --system > /dev/null

echo "[4/6] Verifying kernel modules..."
if lsmod | egrep -q 'overlay|br_netfilter'; then
  lsmod | egrep 'overlay|br_netfilter'
else
  echo "ℹ️  overlay/br_netfilter not listed (likely built into kernel)"
fi

echo "[5/6] Verifying sysctl values..."
sysctl net.bridge.bridge-nf-call-iptables
sysctl net.bridge.bridge-nf-call-ip6tables
sysctl net.ipv4.ip_forward

echo "[6/6] Checking container runtime..."
if command -v containerd >/dev/null 2>&1; then
  containerd --version
else
  echo "⚠️  containerd NOT installed (expected on fresh server)"
  echo "ℹ️  Will be installed in the next phase"
fi

echo
echo "===== Network & Kernel Prerequisites COMPLETE ====="
