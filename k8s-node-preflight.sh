#!/usr/bin/env bash

set -e

echo "===== Kubernetes Node Preflight Script ====="

echo "[1/5] Loading required kernel modules..."
sudo modprobe overlay
sudo modprobe br_netfilter

echo "[2/5] Persisting kernel modules..."
sudo tee /etc/modules-load.d/k8s.conf > /dev/null <<EOF
overlay
br_netfilter
EOF

echo "[3/5] Applying sysctl parameters..."
sudo tee /etc/sysctl.d/k8s.conf > /dev/null <<EOF
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

sudo sysctl --system > /dev/null

echo "[4/5] Verifying kernel modules..."
lsmod | egrep 'overlay|br_netfilter' || echo "⚠️  Modules not listed but may be built-in"

echo "[5/5] Verifying sysctl values..."
sysctl net.bridge.bridge-nf-call-iptables
sysctl net.bridge.bridge-nf-call-ip6tables
sysctl net.ipv4.ip_forward

echo
echo "===== Network & Kernel Prerequisites COMPLETE ====="
echo "containerd version:"
containerd --version || echo "⚠️  containerd not found"
