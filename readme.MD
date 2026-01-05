| Script                      | Run on               | Purpose                                     |
| --------------------------- | -------------------- | ------------------------------------------- |
| `01-k8s-node-preflight.sh`  | Master & Worker      | OS preflight & kernel/network prerequisites |
| `02-containerd-runtime.sh`  | Master & Worker      | Install container runtime                   |
| `03-kubernetes-binaries.sh` | Master only (so far) | Install kubeadm, kubelet, kubectl           |
| `04-k8s-master-init.sh`     | Master only          | Initialize cluster, CNI, kubeconfig         |
| `05-k8s-worker-join.sh`     | Worker               | Join cluster (needs kubeadm)                |
