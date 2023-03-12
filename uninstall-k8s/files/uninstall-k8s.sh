#!/usr/bin/env bash

which kubeadm

if [ $? -eq 0 ];then
expect <<-EOF

spawn kubeadm reset
expect "*y/N*"
send "y\n"
expect eof

EOF
fi

systemctl stop kubelet docker
#yum -y remove keepalived kubelet* kubeadm* docker* ipvsadm nfs-utils
iptables -F && iptables -t nat -F && iptables -t mangle -F && iptables -X

sudo ifconfig cni0 down
sudo ip link delete cni0

> /root/.ssh/known_hosts

rm -rf /etc/kubernetes/*
rm -fr ~/.kube
rm -fr /var/lib/etcd
rm -rf /run/flannel

