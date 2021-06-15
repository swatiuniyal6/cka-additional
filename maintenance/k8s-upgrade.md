
https://v1-19.docs.kubernetes.io/docs/tasks/administer-cluster/kubeadm/kubeadm-upgrade/
# Intial setup 
    apt update
    apt-cache madison kubeadm


#Upgrading control plane nodes 
# check the current version 
$ kubeadm version

# pin the version to 
version=1.19.3-00 
kubeadm_version=v1.19.3

apt-mark unhold kubeadm && \
apt-get update && apt-get install -y kubeadm=$version && \
apt-mark hold kubeadm

# kubeadm upgrade


sudo kubeadm upgrade apply $kubeadm_version

kubeadm completed. 

# Upgrade additional control plane nodes 

sudo kubeadm upgrade node

Drain the control plane node
Prepare the node for maintenance by marking it unschedulable and evicting the workloads:

# replace <cp-node-name> with the name of your control plane node
kubectl drain <cp-node-name> --ignore-daemonsets

# Upgrade kubelet and kubectl 

apt-mark unhold kubelet kubectl && \
apt-get update && apt-get install -y kubelet=$version kubectl=$version && \
apt-mark hold kubelet kubectl

# restart the componets 
sudo systemctl daemon-reload
sudo systemctl restart kubelet

Uncordon the control plane node 

kubectl uncordon controlplane

### Upgrade worker nodes 

Upgrade kubeadm 
version=1.19.3-00 
kubeadm_version=v1.19.3

apt-mark unhold kubeadm && \
apt-get update && apt-get install -y kubeadm=$version && \
apt-mark hold kubeadm

sudo kubeadm upgrade node


# Upgrade kubelet and kubectl 

apt-mark unhold kubelet kubectl && \
apt-get update && apt-get install -y kubelet=$version kubectl=$version && \
apt-mark hold kubelet kubectl

#    (from-master)


# restart the componets 
sudo systemctl daemon-reload
sudo systemctl restart kubelet

#Uncordon the worker  node 

# kubectl uncordon node01


# kubectl get nodes to confirm 