#!/usr/bin/env bash
set -e

echo "===== Phase 4: Kubernetes Master Node Initialization ====="

# Must be run as root
if [[ $EUID -ne 0 ]]; then
  echo "❌ Please run as root or with sudo"
  exit 1
fi

# ----------------------------
# 1️⃣ Detect master IP
# ----------------------------
# Auto-detect primary IP
MASTER_IP=$(hostname -I | awk '{print $1}')

echo "⚠️  NOTE: Detected master node IP: $MASTER_IP"
echo "⚠️  WARNING: This IP may change next time the server restarts or is recreated in your lab."
echo

# ----------------------------
# 2️⃣ Initialize kubeadm
# ----------------------------
echo "[1/4] Initializing Kubernetes control plane..."
kubeadm init \
  --apiserver-advertise-address=$MASTER_IP \
  --pod-network-cidr=10.244.0.0/16 \
  --ignore-preflight-errors=all

# ----------------------------
# 3️⃣ Setup kubectl for the current user
# ----------------------------
echo "[2/4] Setting up kubeconfig..."
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# ----------------------------
# 4️⃣ Install CNI plugin (Flannel)
# ----------------------------
echo "[3/4] Installing Flannel CNI..."
kubectl apply -f https://raw.githubusercontent.com/flannel-io/flannel/master/Documentation/kube-flannel.yml

# ----------------------------
# 5️⃣ Print join command for worker nodes
# ----------------------------
echo "[4/4] Generating kubeadm join command..."
JOIN_COMMAND=$(kubeadm token create --print-join-command)
echo
echo "✅ Use the following command to join worker nodes to this cluster:"
echo
echo "$JOIN_COMMAND"
echo
echo "⚠️  REMEMBER: If you restart this master node, the IP may change, and you need to regenerate the join command."
echo

echo "===== Phase 4 COMPLETE: Master node initialized ====="
