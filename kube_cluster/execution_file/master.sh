#!/bin/bash


# hosts file
sudo tee /etc/hosts<<EOF
192.168.11.147 EPC02
192.168.11.148 EPC03
192.168.11.149 EPC04
192.168.11.151 EPC05
192.168.11.152 EPC06
192.168.11.153 EPC07
127.0.0.1 localhost

EOF

sudo apt update -y



# 2) Install kubelet, kubeadm and kubectl
# Once the servers are rebooted, add Kubernetes repository for Ubuntu 22.04 to all the servers.

sudo apt install curl apt-transport-https ca-certificates curl gpg -y

curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.28/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.28/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list

sudo apt update
sudo apt install wget curl vim git -y
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl

# Confirm installation by checking the version of kubectl.
kubectl version --client && kubeadm version

# 3) Disable Swap Space
# Disable all swaps from /proc/swaps.
sudo swapoff -a
sudo sed -i '/swap/ s/^\(.*\)$/#\1/g' /etc/fstab

# Enable kernel modules and configure sysctl.

# Configure persistent loading of modules
sudo tee /etc/modules-load.d/k8s.conf <<EOF
overlay
br_netfilter
EOF

cat >>/etc/modules-load.d/crio.conf<<EOF
overlay
br_netfilter
EOF
# Load at runtime
sudo modprobe overlay
sudo modprobe br_netfilter

# Ensure sysctl params are set
sudo tee /etc/sysctl.d/k8s.conf<<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF

# Reload configs
sudo sysctl --system

# Install required packages
sudo apt install -y curl gnupg2 software-properties-common apt-transport-https ca-certificates

# Install CRIO
export OS=xUbuntu_20.04
export CRIO_VERSION=1.23


echo "deb https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/$OS/ /"|sudo tee /etc/apt/sources.list.d/devel:kubic:libcontainers:stable.list
echo "deb http://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable:/cri-o:/$CRIO_VERSION/$OS/ /"|sudo tee /etc/apt/sources.list.d/devel:kubic:libcontainers:stable:cri-o:$CRIO_VERSION.list

curl -L https://download.opensuse.org/repositories/devel:kubic:libcontainers:stable:cri-o:$CRIO_VERSION/$OS/Release.key | sudo apt-key add -
curl -L https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/$OS/Release.key | sudo apt-key add -

sudo apt update
sudo apt install cri-o cri-o-runc

# Enable systemd configure
systemctl daemon-reload
systemctl enable --now crio

# 5) Initialize control plane (run on first master node)
# Login to the server to be used as master and make sure that the br_netfilter module is loaded:

lsmod | grep br_netfilter


# # We now want to initialize the machine that will run the control plane components which includes etcd (the cluster database) and the API Server.
# sudo kubeadm init --pod-network-cidr=10.244.0.0/16 --cri-socket unix:///var/run/crio/crio.sock >> ./logs/master_log.sh

# # Configure kubectl using commands in the output:
# mkdir -p $HOME/.kube
# sudo cp -f /etc/kubernetes/admin.conf $HOME/.kube/config
# sudo chown $(id -u):$(id -g) $HOME/.kube/config

# # Cài CNI Flanel
# kubectl apply -f https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml

