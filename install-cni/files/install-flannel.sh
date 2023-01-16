#!/usr/bin/env bash

# 去掉master污点
kubectl taint nodes `hostname` node-role.kubernetes.io/master:NoSchedule- 2>/dev/null
kubectl taint nodes `hostname` node.kubernetes.io/not-ready:NoSchedule- 2>/dev/null

# For Kubernetes v1.17+
kubectl apply -f https://raw.githubusercontent.com/flannel-io/flannel/v0.20.2/Documentation/kube-flannel.yml

# 查看
kubectl get all -n kube-flannel

# 持续检查
while true
do
   kubectl get pods -n kube-flannel|grep -q '0/1'
   if [ $? -ne 0 ];then
      echo "flannel started"
      break
    else
      echo "flannel starting..."
    fi
    sleep 1
done
