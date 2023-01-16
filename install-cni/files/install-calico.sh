#!/usr/bin/env bash

wget https://docs.projectcalico.org/manifests/calico.yaml -O /tmp/calico.yaml
kubectl apply -f /tmp/calico.yaml

# 查看
kubectl get all -n kube-system|grep calico
