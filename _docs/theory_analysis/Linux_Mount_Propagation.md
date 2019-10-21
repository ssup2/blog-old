---
title: Linux Bind Mount / Mount Propagation
category:
date: 2019-10-20T12:00:00Z
lastmod: 2019-10-20T12:00:00Z
comment: true
adsense: true
---

Linux의 Mount Propagation을 정리한다.

### 1. Linux Mount Propagation

![[그림 1] Clone Mount Namespace]({{site.baseurl}}/images/theory_analysis/Linux_Mount_Propagation/Clone_Mount_NS.PNG){: width="700px"}

![[그림 2] Bind Mount]({{site.baseurl}}/images/theory_analysis/Linux_Mount_Propagation/Bind_Mount.PNG){: width="700px"}

![[그림 3] Forward Propagation]({{site.baseurl}}/images/theory_analysis/Linux_Mount_Propagation/Forward_Propagation.PNG){: width="700px"}

![[그림 4] Receive Propagation]({{site.baseurl}}/images/theory_analysis/Linux_Mount_Propagation/Receive_Propagation.PNG){: width="700px"}

### 2. 참조

* [https://unix.stackexchange.com/questions/198590/what-is-a-bind-mount](https://unix.stackexchange.com/questions/198590/what-is-a-bind-mount)
* [https://lwn.net/Articles/689856/](https://lwn.net/Articles/689856/)
* [https://www.kernel.org/doc/Documentation/filesystems/sharedsubtree.txt](https://www.kernel.org/doc/Documentation/filesystems/sharedsubtree.txt)
* [https://docs.docker.com/storage/bind-mounts/](https://docs.docker.com/storage/bind-mounts/)
