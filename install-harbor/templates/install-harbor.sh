#!/usr/bin/env bash

helm list -n harbor|grep -q 'harbor'

if [ $? -eq 0 ];then
   exit 0
fi

mkdir stl && cd stl
# 生成 CA 证书私钥
openssl genrsa -out ca.key 4096
# 生成 CA 证书
openssl req -x509 -new -nodes -sha512 -days 3650 \
 -subj "/C=CN/ST=Guangdong/L=Shenzhen/O=harbor/OU=harbor/CN={{ harbor_domainname }}" \
 -key ca.key \
 -out ca.crt
# 创建域名证书，生成私钥
openssl genrsa -out {{ harbor_domainname }}.key 4096
# 生成证书签名请求 CSR
openssl req -sha512 -new \
    -subj "/C=CN/ST=Guangdong/L=Shenzhen/O=harbor/OU=harbor/CN={{ harbor_domainname }}" \
    -key {{ harbor_domainname }}.key \
    -out {{ harbor_domainname }}.csr
# 生成 x509 v3 扩展
cat > v3.ext <<-EOF
authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
extendedKeyUsage = serverAuth
subjectAltName = @alt_names

[alt_names]
DNS.1={{ harbor_domainname }}
DNS.2=*.{{ harbor_domainname }}
DNS.3=hostname
EOF
#创建 Harbor 访问证书
openssl x509 -req -sha512 -days 3650 \
    -extfile v3.ext \
    -CA ca.crt -CAkey ca.key -CAcreateserial \
    -in {{ harbor_domainname }}.csr \
    -out {{ harbor_domainname }}.crt

kubectl create secret tls {{ harbor_domainname }} --key {{ harbor_domainname }}.key --cert {{ harbor_domainname }}.crt -n harbor
kubectl get secret {{ harbor_domainname }} -n harbor

# 在线安装需要配置源
# helm repo add harbor https://helm.goharbor.io

# 下载安装包
# helm pull harbor/harbor
# harbor-1.11.1.tgz 安装包在提供的资源包里是有的，可以不用再去外网下载的。
helm install myharbor /tmp/harbor-1.11.1.tgz \
  --namespace=harbor --create-namespace \
  --set expose.ingress.hosts.core={{ harbor_domainname }} \
  --set expose.ingress.hosts.notary=notary.{{ harbor_domainname }} \
  --set-string expose.ingress.annotations.'nginx\.org/client-max-body-size'="1024m" \
  --set expose.tls.secretName={{ harbor_domainname }} \
  --set persistence.persistentVolumeClaim.registry.storageClass=nfs-client \
  --set persistence.persistentVolumeClaim.jobservice.storageClass=nfs-client \
  --set persistence.persistentVolumeClaim.database.storageClass=nfs-client \
  --set persistence.persistentVolumeClaim.redis.storageClass=nfs-client \
  --set persistence.persistentVolumeClaim.trivy.storageClass=nfs-client \
  --set persistence.persistentVolumeClaim.chartmuseum.storageClass=nfs-client \
  --set persistence.enabled=true \
  --set externalURL=https://{{ harbor_domainname }} \
  --set harborAdminPassword=Harbor12345
