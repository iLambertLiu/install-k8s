#!/usr/bin/env bash

kubectl apply -f /tmp/dashboard.yaml

cat >ServiceAccount.yaml<<EOF
apiVersion: v1
kind: ServiceAccount
metadata:
  name: admin-user
  namespace: kubernetes-dashboard
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: admin-user
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: ServiceAccount
  name: admin-user
  namespace: kubernetes-dashboard
EOF
kubectl apply -f ServiceAccount.yaml

kubectl -n kubernetes-dashboard create token admin-user

# 查看
kubectl get pods,svc -n kubernetes-dashboard
