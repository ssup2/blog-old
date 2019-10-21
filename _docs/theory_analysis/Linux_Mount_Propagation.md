---
title: Linux Mount Propagation
category: Theory, Analysis
date: 2019-10-20T12:00:00Z
lastmod: 2019-10-20T12:00:00Z
comment: true
adsense: true
---

Linux의 Mount Propagation을 분석한다.

### 1. Linux Mount Propagation

Mount Propagation은 Linux Kernel의 Mount NS(Namespace)으로 인해 발생하는 관리의 불편함을 해결하기 위해 나온 기법이다. Mount Propagation을 이용하지 않는다면 다수의 Mount NS가 존재하는 상태에서 모든 Process들이 Mount되어 있지 않는 Block Device를 이용하기 위해서는, Mount NS의 개수만큼 Block Device Mount를 수행 해야 한다. 하지만 Mount Propagation을 적절히 이용하면 한번의 Block Device Mount로 모든 Mount NS에서 Block Device Mount를 수행할 수 있게 된다.

#### 1.1. Shared Subtree

![[그림 1] Clone Mount Namespace]({{site.baseurl}}/images/theory_analysis/Linux_Mount_Propagation/Clone_Mount_NS.PNG){: width="700px"}

![[그림 2] Bind Mount]({{site.baseurl}}/images/theory_analysis/Linux_Mount_Propagation/Bind_Mount.PNG){: width="700px"}

#### 1.2. Mount Propagation

![[그림 3] Forward Propagation]({{site.baseurl}}/images/theory_analysis/Linux_Mount_Propagation/Forward_Propagation.PNG){: width="700px"}

![[그림 4] Receive Propagation]({{site.baseurl}}/images/theory_analysis/Linux_Mount_Propagation/Receive_Propagation.PNG){: width="700px"}

#### 1.3. Mount Option

### 2. 참조

* [https://unix.stackexchange.com/questions/198590/what-is-a-bind-mount](https://unix.stackexchange.com/questions/198590/what-is-a-bind-mount)
* [https://lwn.net/Articles/689856/](https://lwn.net/Articles/689856/)
* [https://www.kernel.org/doc/Documentation/filesystems/sharedsubtree.txt](https://www.kernel.org/doc/Documentation/filesystems/sharedsubtree.txt)
* [https://docs.docker.com/storage/bind-mounts/](https://docs.docker.com/storage/bind-mounts/)
