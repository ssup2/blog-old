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

Mount Propagation은 Linux Kernel의 Mount NS(Namespace)으로 인해 발생하는 관리의 불편함을 해결하기 위해 나온 기법이다. Mount Propagation을 이용하지 않는다면 다수의 Mount NS가 존재하는 상태에서 모든 Process들이 Mount되어 있지 않는 Block Device를 이용하기 위해서는, Mount NS의 개수만큼 Block Device Mount를 수행해야 한다. 하지만 Mount Propagation을 적절히 이용하면 한번의 Block Device Mount로 모든 Mount NS에서 Block Device Mount를 수행할 수 있게 된다.

#### 1.1. Shared Subtree

![[그림 1] Mount Namespace Clone]({{site.baseurl}}/images/theory_analysis/Linux_Mount_Propagation/Mount_NS_Clone.PNG){: width="700px"}

Mount Propagation을 이해하기 위해서는 Shared Subtree의 개념을 알아야 한다. 여기서 Subtree는 Filesystem Tree의 일부를 구성하는 Filesystem을 의미한다. [그림 1]에서 왼쪽은 Filesystem Tree는 Root에 Mount된 Filesystem과 /A Directory에 Mount된 Filesystem, 2개의 Subtree로 구성되어 있는 Filesystem을 나타내고 있다. 이러한 Subtree를 Share(공유)하면 Shared Subtree가 된다.

Subtree를 공유하는 방법은 Mount NS를 Clone(복제)하는 방법과 Bind Mount를 이용하는 방법 2가지가 존재한다. [그림 1]은 Mount NS를 Clone하여 Shared Subtree를 생성하는 방법을 나타내고 있다. Clone() System Call을 이용하여 Mount NS를 복제할 경우 Mount NS안에 저장되어 있던 Mount 정보도 그대로 복제된다. Subtree도 그대로 복제되기 Subtree는 Mount NS 사이에서 공유된다. [그림 1]에서는 2개의 Subtree가 있기 때문에, 2개의 Subtree가 그대로 복제되는 모습을 나타내고 있다. 원본 Mount NS의 Subtree를 Parent라고 표현하였고, 복제된 Mount NS의 Subtree를 Child라고 표현하였다.

![[그림 2] Bind Mount]({{site.baseurl}}/images/theory_analysis/Linux_Mount_Propagation/Bind_Mount.PNG){: width="700px"}

[그림 2]는 Bind Mount를 이용하여 Shared Subtree를 생성하는 방법을 나타내고 있다. Bind Mount를 이용하면 Subtree를 다른 Directory에 붙여 공유할수 있게된다. 원본 Subtree는 Parent라고 표현하였고, Bind Mount에 의해서 공유된 Subtree는 Child라고 표현하였다.

#### 1.2. Mount Propagation

Mount Propagation은 의미 그대로 변경된 Mount 정보를 전파하는 기법이다. 여기서 전파 범위는 Shared Subtree로 한정된다. Mount Propagation을 이용하지 않으면 Shared Subtree라고 하더라도 Mount 정보는 각 Subtree별로 관리된다. Parent에서 Child로 변경된 Mount 정보가 전파 되는걸 Forward Propagation이라고 한다. 반대로 Child에서 Parent로 변경된 Mount 정보가 전파 되는걸 Receive Propagation이라고 한다.

![[그림 3] Forward Propagation]({{site.baseurl}}/images/theory_analysis/Linux_Mount_Propagation/Forward_Propagation.PNG){: width="700px"}

[그림 3]은 Mount NS 사이의 Shared Subtree에서 Forward Propagation이 발생하는 과정을 나타내고 있다. 순서는 다음과 같다.

* 원본 Mount NS의 Subtree는 Clone() System Call을 공유상태가 된다.
* Parent Subtree의 /A Directory에 sdb Block Device를 Mount 하였다.
* Forward Propagation이 발생하여 Child Subtree의 /A Directory에도 sdb Block Device가 Mount 된다.

![[그림 4] Receive Propagation]({{site.baseurl}}/images/theory_analysis/Linux_Mount_Propagation/Receive_Propagation.PNG){: width="700px"}

[그림 4]는 Mount NS 사이의 Shared Substree에서 Receive Propagation이 발생하는 과정을 나타내고 있다. 순서는 다음과 같다.

* 원본 Mount NS의 Subtree는 Clone() System Call을 공유상태가 된다.
* Child Subtree의 /A Directory에 sdb Block Device를 Mount 하였다.
* Receive Propagation이 발생하여 Parent Subtree의 /A Directory에도 sdb Block Device가 Mount 된다.

#### 1.3. Mount Option

### 2. 참조

* [https://unix.stackexchange.com/questions/198590/what-is-a-bind-mount](https://unix.stackexchange.com/questions/198590/what-is-a-bind-mount)
* [https://lwn.net/Articles/689856/](https://lwn.net/Articles/689856/)
* [https://www.kernel.org/doc/Documentation/filesystems/sharedsubtree.txt](https://www.kernel.org/doc/Documentation/filesystems/sharedsubtree.txt)
* [https://docs.docker.com/storage/bind-mounts/](https://docs.docker.com/storage/bind-mounts/)
