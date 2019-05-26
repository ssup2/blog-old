---
title: istio Architecture
category:
date: 2019-05-14T12:00:00Z
lastmod: 2019-05-15T12:00:00Z
comment: true
adsense: true
---

### 1. istio Architecture

Where Kubernetes/OpenShift itself gives you default round-robin load balancing
behind its service construct, Istio allows you to introduce unique and finely
grained routing rules among all services within the mesh.

root@kube03:~# nsenter -t 126126 -n --root=/ iptables -t nat -nvL
Chain PREROUTING (policy ACCEPT 499 packets, 29940 bytes)
 pkts bytes target     prot opt in     out     source               destination

Chain INPUT (policy ACCEPT 499 packets, 29940 bytes)
 pkts bytes target     prot opt in     out     source               destination

Chain OUTPUT (policy ACCEPT 431 packets, 39469 bytes)
 pkts bytes target     prot opt in     out     source               destination
   25  1500 ISTIO_OUTPUT  tcp  --  *      *       0.0.0.0/0            0.0.0.0/0

Chain POSTROUTING (policy ACCEPT 440 packets, 40009 bytes)
 pkts bytes target     prot opt in     out     source               destination

Chain ISTIO_IN_REDIRECT (0 references)
 pkts bytes target     prot opt in     out     source               destination
    0     0 REDIRECT   tcp  --  *      *       0.0.0.0/0            0.0.0.0/0            redir ports 15001

Chain ISTIO_OUTPUT (1 references)
 pkts bytes target     prot opt in     out     source               destination
    0     0 ISTIO_REDIRECT  all  --  *      lo      0.0.0.0/0           !127.0.0.1
   16   960 RETURN     all  --  *      *       0.0.0.0/0            0.0.0.0/0            owner UID match 1337
    0     0 RETURN     all  --  *      *       0.0.0.0/0            0.0.0.0/0            owner GID match 1337
    0     0 RETURN     all  --  *      *       0.0.0.0/0            127.0.0.1
    9   540 ISTIO_REDIRECT  all  --  *      *       0.0.0.0/0            0.0.0.0/0

Chain ISTIO_REDIRECT (2 references)
 pkts bytes target     prot opt in     out     source               destination
    9   540 REDIRECT   tcp  --  *      *       0.0.0.0/0            0.0.0.0/0            redir ports 15001

### 2. 참조

* Introducing Istio Service Mesh for Microservices
* [https://istio.io/docs/concepts/what-is-istio/](https://istio.io/docs/concepts/what-is-istio/)