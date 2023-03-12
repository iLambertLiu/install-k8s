#!/usr/bin/env bash

echo "====================k8s node join=======================" | tee -a /tmp/k8s.log

hostname=`hostname`

for i in `seq 3`
do

# 判断节点是否加入
ssh {{ endpoint }} "kubectl get nodes|grep -q ${hostname}"
if [ $? -eq 0 ];then
	break
fi

expect <<-EOF
pawn kubeadm reset
expect "*y/N*"
send "y\n"
expect eof

EOF
iptables -F && iptables -t nat -F && iptables -t mangle -F && iptables -X

CERT_KEY=`ssh {{ endpoint }} "kubeadm init phase upload-certs --upload-certs|tail -1"`

join_str=`ssh {{ endpoint }} kubeadm token create --print-join-command`

$( echo $join_str " --certificate-key $CERT_KEY --v=5") | tee -a /tmp/k8s.log

done

# 如果初始化失败了，就异常退出
ssh {{ endpoint }} "kubectl get nodes|grep -q ${hostname}"
if [ $? -ne 0 ];then
   echo "k8s node join failed!!!";exit 1
fi

echo "====================k8s node join end=======================" | tee -a /tmp/k8s.log
