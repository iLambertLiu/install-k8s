#!/usr/bin/env bash

kubectl get nodes 1>&2 >/dev/null
if [ $? -eq 0 ];then
   exit 0
fi

ip=`hostname -i`

kubeadm init \
  --apiserver-advertise-address=$ip \
  --image-repository registry.aliyuncs.com/google_containers \
  --kubernetes-version v{{ k8s_version }} \
  --control-plane-endpoint=$ip \
  --service-cidr=10.1.0.0/16 \
  --pod-network-cidr=10.244.0.0/16 \
  --v=5

mkdir -p $HOME/.kube
rm -rf $HOME/.kube/config
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

