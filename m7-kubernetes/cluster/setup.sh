#!/bin/bash
set -euo pipefail

echo "=== Master Setup: $HOSTNAME ==="
sudo swapoff -a
cat /proc/swaps
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab
sudo modprobe overlay
sudo modprobe br_netfilter
echo 'overlay' | sudo tee -a /etc/modules-load.d/kubernetes.conf
echo 'br_netfilter' | sudo tee -a /etc/modules-load.d/kubernetes.conf
sudo sysctl net.bridge.bridge-nf-call-iptables=1
sudo sysctl net.bridge.bridge-nf-call-ip6tables=1
echo 'net.bridge.bridge-nf-call-iptables=1' | sudo tee -a /etc/sysctl.conf
echo 'net.bridge.bridge-nf-call-ip6tables=1' | sudo tee -a /etc/sysctl.conf
sudo sysctl -p

# Docker repo
sudo apt update -qq
sudo apt install -y ca-certificates curl gnupg lsb-release
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Containerd
sudo apt update -qq
sudo apt install -y --reinstall containerd.io -o Dpkg::Options::="--force-confnew"
sudo mkdir -p /etc/containerd
containerd config default | sudo tee /etc/containerd/config.toml >/dev/null
sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml
sudo systemctl restart containerd
sudo systemctl enable containerd

# IP forwarding
sudo sysctl net.ipv4.ip_forward=1
echo 'net.ipv4.ip_forward=1' | sudo tee -a /etc/sysctl.conf
sudo sysctl -p
# Kubernetes v1.30
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.30/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-archive-keyring.gpg
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-archive-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.30/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list > /dev/null
sudo apt update -qq
sudo apt install -y kubelet=1.30.0-1.1 kubeadm=1.30.0-1.1 kubectl
sudo apt-mark hold kubelet kubeadm kubectl

echo "$HOSTNAME fully ready!"
sudo systemctl is-active containerd
sudo kubeadm version

echo "=== Initializing Kubernetes cluster with IP: $MASTER_IP ==="
sudo kubeadm init \
  --pod-network-cidr=10.244.0.0/16 \
  --cri-socket=unix:///run/containerd/containerd.sock \
  --apiserver-advertise-address=$MASTER_IP

