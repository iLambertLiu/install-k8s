#!/usr/bin/env bash

expect <<-EOF

spawn kubeadm reset
expect "*y/N*"
send "y\n"
expect eof

EOF

rm -rf /etc/kubernetes/*
rm -fr ~/.kube
rm -fr /var/lib/etcd
