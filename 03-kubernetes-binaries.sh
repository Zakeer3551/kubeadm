#!/usr/bin/env bash
set -e

echo "===== Phase 3: Kubernetes Binaries ====="

# Must be run as root
if [[ $EUID -ne 0 ]]; then
  echo "❌ Please run as root or with sudo"
  exit 1
fi

echo "[1/7] Installing apt dependencies..."
apt-get update -y
apt-get install -y apt-transport-https ca-certificates curl gpg

echo "[2/7] Adding Kubernetes apt repository..."
mkdir -p /etc/apt/keyrings
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.29/deb/Release.key \
  | gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] \
https://pkgs.k8s.io/core:/stable:/v1.29/deb/ /" \
> /etc/apt/sources.list.d/kubernetes.list

echo "[3/7] Updating apt cache..."
apt-get update -y

echo "[4/7] Installing kubelet, kubeadm, kubectl..."
apt-get install -y kubelet kubeadm kubectl

echo "[5/7] Holding Kubernetes packages..."
apt-mark hold kubelet kubeadm kubectl

echo "[6/7] Enabling kubelet service..."
systemctl enable kubelet

echo "[7/7] Verifying installation..."
kubeadm version
kubectl version --client
kubelet --version

echo
echo "NOTE: kubelet may be inactive until kubeadm init/join"
systemctl --no-pager status kubelet | grep -E "Loaded:|Active:"

echo
echo "===== Phase 3 COMPLETE: Kubernetes Binaries Installed ====="
