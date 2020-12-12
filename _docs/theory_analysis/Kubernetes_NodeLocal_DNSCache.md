---
title: Kubernetes NodeLocal DNSCache
category: Theory, Analysis
date: 2020-12-14T12:00:00Z
lastmod: 2020-12-14T12:00:00Z
comment: true
adsense: true
---

Kubernetes의 NodeLocal DNSCache룰 분석한다.

### 1. Kubernetes NodeLocal DNSCache

![[그림 1] Kubernetes NodeLocal DNSCache Architecture]({{site.baseurl}}/images/theory_analysis/Kubernetes_NodeLocal_DNSCache/Kubernetes_NodeLocal_DNSCache.PNG){: width="700px"}

### 2. 참조

* [https://kubernetes.io/docs/tasks/administer-cluster/nodelocaldns/](https://kubernetes.io/docs/tasks/administer-cluster/nodelocaldns/)
* [https://github.com/kubernetes/enhancements/blob/master/keps/sig-network/20190424-NodeLocalDNS-beta-proposal.md](https://github.com/kubernetes/enhancements/blob/master/keps/sig-network/20190424-NodeLocalDNS-beta-proposal.md)
* [https://github.com/kubernetes/enhancements/blob/master/keps/sig-network/0030-nodelocal-dns-cache.md](https://github.com/kubernetes/enhancements/blob/master/keps/sig-network/0030-nodelocal-dns-cache.md)
* [https://github.com/kubernetes/kubernetes/issues/45363#issuecomment-443019910](https://github.com/kubernetes/kubernetes/issues/45363#issuecomment-443019910)
* [https://cloud.google.com/kubernetes-engine/docs/how-to/nodelocal-dns-cache](https://cloud.google.com/kubernetes-engine/docs/how-to/nodelocal-dns-cache)
* [https://github.com/kubernetes-sigs/kubespray/blob/master/docs/dns-stack.md](https://github.com/kubernetes-sigs/kubespray/blob/master/docs/dns-stack.md)
* [https://github.com/colopl/k8s-local-dns](https://github.com/colopl/k8s-local-dns)
* [https://povilasv.me/kubernetes-node-local-dns-cache/](https://povilasv.me/kubernetes-node-local-dns-cache/)