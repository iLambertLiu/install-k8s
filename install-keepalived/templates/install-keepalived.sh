#!/bin/bash

yum -y install keepalived

/bin/cp -f /tmp/keepalived.conf /etc/keepalived/keepalived.conf

systemctl restart keepalived

