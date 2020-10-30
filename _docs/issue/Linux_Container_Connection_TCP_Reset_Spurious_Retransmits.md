---
title: Linux Container Connection Reset with TCP Spurious Retransmits
category: Issue
date: 2020-10-31T12:00:00Z
lastmod: 2020-10-31T12:00:00Z
comment: true
adsense: true
---

### 1. Issue

Container에서 Host 외부로 Packet을 전송하면서 전송한 Packet이 SNAT 되는 경우 TCP Spurious으로 인해서 TCP Connection이 Reset되는 Issue가 존재한다. Container안에서 Client가 동작하고 Host 외부에 Server가 동작하는 경우 Client가 전송한 Packet은 SNAT되어 Host 외부로 전달된다. Container의 Client와 Host 외부에 Server가 HTTP Protocol 처럼 짧은 시간동안 적은 양의 Packet을 전송하는 경우에는 문제 없지만, 오랜 시간동안 TCP Connection을 맺으면서 많은양의 Packet을 전송하는 경우에는 본 이슈가 발생할 확률이 높다.

Docker Container의 경우 Host 외부로 Packet을 전송하는 경우에 Packet을 SNAT하여 전송하기 때문에 본 이슈가 발생할 수 있다. 또한 Kubernetes Pod의 Container 내부에서 Kubernetes Cluster 외부의 Server와 TCP Connection을 맺는 경우, Kubernetes Pod의 Container가 전송한 TCP SYN Packet은 SNAT 되어 외부로 전송되기 때문에 본 Issue가 발생할 수 있다.

### 2. 원인, 해결 방안

### 3. 참조

* [https://github.com/moby/libnetwork/issues/1090](https://github.com/moby/libnetwork/issues/1090)
* [https://github.com/moby/libnetwork/issues/1090#issuecomment-425421288](https://github.com/moby/libnetwork/issues/1090#issuecomment-425421288)
* [https://imbstack.com/2020/05/03/debugging-docker-connection-resets.html](https://imbstack.com/2020/05/03/debugging-docker-connection-resets.html)
* [https://github.com/kubernetes/kubernetes/pull/74840#issuecomment-491674987](https://github.com/kubernetes/kubernetes/pull/74840#issuecomment-491674987)
