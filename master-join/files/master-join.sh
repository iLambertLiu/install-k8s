#!/usr/bin/env bash

# 在第一个master节点上执行以下获取执行命令
# 证如果过期了，可以使用下面命令生成新证书上传，这里会打印出certificate key，后面会用到
maser_ip=`head -1 /tmp/hosts |awk '{print $1}'`

# 判断节点是否加入
ssh $maser_ip "kubectl get nodes|grep -q `hostname`"
if [ $? -eq 0 ];then
	exit 0
fi

CERT_KEY=`ssh $maser_ip "kubeadm init phase upload-certs --upload-certs|tail -1"`

join_str=`ssh $maser_ip kubeadm token create --print-join-command`

$( echo $join_str " --control-plane --certificate-key $CERT_KEY --v=5")

# 拿到上面打印的命令在需要添加的节点上执行

# --control-plane 标志通知 kubeadm join 创建一个新的控制平面。加入master必须加这个标记
# --certificate-key ... 将导致从集群中的 kubeadm-certs Secret 下载控制平面证书并使用给定的密钥进行解密。这里的值就是上面这个命令（kubeadm init phase upload-certs --upload-certs）打印出的key。

mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# 去掉master污点
kubectl taint nodes `hostname` node-role.kubernetes.io/master:NoSchedule- 2>/dev/null
kubectl taint nodes `hostname` node.kubernetes.io/not-ready:NoSchedule- 2>/dev/null
