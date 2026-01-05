#!/usr/bin/env bash
set -e

echo "===== Phase 5: Kubernetes Worker Node Join ====="

# Must be run as root
if [[ $EUID -ne 0 ]]; then
  echo "❌ Please run as root or with sudo"
  exit 1
fi

# ----------------------------
# 1️⃣ Prompt for kubeadm join command
# ----------------------------
echo "⚠️  NOTE: Worker node will join the cluster using the kubeadm join command from the master."
echo "⚠️  WARNING: If the master node IP has changed since the last lab session, you must get the new join command."
echo

read -p "Enter the full kubeadm join command from the master node: " JOIN_CMD

if [[ -z "$JOIN_CMD" ]]; then
  echo "❌ No join command provided. Exiting."
  exit 1
fi

# ----------------------------
# 2️⃣ Execute kubeadm join
# ----------------------------
echo "[1/2] Joining worker node to the cluster..."
sudo $JOIN_CMD

# ----------------------------
# 3️⃣ Verify node has joined
# ----------------------------
echo "[2/2] Verifying node joined..."
echo "⚠️  Run this on the master node using 'kubectl get nodes' to see this worker."
echo

echo "===== Phase 5 COMPLETE: Worker node joined ====="
