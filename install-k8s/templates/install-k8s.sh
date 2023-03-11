#!/usr/bin/env bash

# 检查是否已经安装
yum list installed kubelet
if [ $? -eq 0 ];then
   exit 0
fi

cat > /etc/yum.repos.d/kubernetes.repo << EOF
[k8s]
name=k8s
enabled=1
gpgcheck=0
baseurl=https://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64/
EOF

# disableexcludes=kubernetes：禁掉除了这个kubernetes之外的别的仓库
yum install -y kubelet-{{ k8s_version }} kubeadm-{{ k8s_version }} kubectl-{{ k8s_version }} --disableexcludes=kubernetes

# 设置为开机自启并现在立刻启动服务 --now：立刻启动服务
systemctl enable --now kubelet

# 查看状态，这里需要等待一段时间再查看服务状态，启动会有点慢
systemctl status kubelet

# 提前下载好
docker pull registry.aliyuncs.com/google_containers/kube-apiserver:v{{ k8s_version }}
docker pull registry.aliyuncs.com/google_containers/kube-controller-manager:v{{ k8s_version }}
docker pull registry.aliyuncs.com/google_containers/kube-scheduler:v{{ k8s_version }}
docker pull registry.aliyuncs.com/google_containers/kube-proxy:v{{ k8s_version }}
docker pull registry.aliyuncs.com/google_containers/pause:3.6
docker pull registry.aliyuncs.com/google_containers/etcd:3.5.1-0
docker pull registry.aliyuncs.com/google_containers/coredns:v1.8.6
