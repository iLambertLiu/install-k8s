#!/usr/bin/env bash

kubectl get nodes 1>&2 >/dev/null
if [ $? -eq 0 ];then
   exit 0
fi

#ip=`grep 'cluster-endpoint' /etc/hosts |awk '{print $1}'`
#endpoint=`grep 'cluster-endpoint' /etc/hosts |awk '{print $2}'`

echo "====================k8s master init=======================" | tee -a /tmp/k8s.log

#kubeadm init \
#  --apiserver-advertise-address=$ip \
#  --image-repository registry.aliyuncs.com/google_containers \
#  --kubernetes-version v{{ k8s_version }} \
#  --control-plane-endpoint=$endpoint \
#  --service-cidr=10.1.0.0/16 \
#  --pod-network-cidr=10.244.0.0/16 \
#  --v=5

echo "kubeadm init --config=/tmp/kubeadm-config.yaml --upload-certs --v=5 | tee -a /tmp/k8s.log" | tee -a /tmp/k8s.log

# 重试三次
for i in `seq 3`
do

# 如果已经初始化了，就跳出循环
kubectl get nodes|grep -q 'control-plane,master'
if [ $? -eq 0 ];then
   break
fi
expect <<-EOF

spawn kubeadm reset
expect "*y/N*"
send "y\n"
expect eof

EOF

iptables -F && iptables -t nat -F && iptables -t mangle -F && iptables -X

kubeadm init --config=/tmp/kubeadm-config.yaml --upload-certs --v=5 | tee -a /tmp/k8s.log

mkdir -p $HOME/.kube
sudo /bin/cp -f /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

sleep 2

done

# 如果初始化失败了，就异常退出
kubectl get nodes|grep -q 'control-plane,master'
if [ $? -ne 0 ];then
   echo "k8s master init failed!!!";exit 1
fi

echo "====================k8s master init end=======================" | tee -a /tmp/k8s.log

