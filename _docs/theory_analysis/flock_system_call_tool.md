---
title: flock System Call and Tool
category: Theory, Analysis
date: 2017-01-30T22:21:00Z
lastmod: 2017-01-30T22:21:00Z
comment: true
adsense: true
---

Unix System의 System Call중 하나인 flock System Call을 이해하고, Linux에서 flock System Call을 이용하여 제작된 File Lock Tool인 flock Tool을 분석한다.

### 1. flock System Call

> int flock(int fd, int operation)

* 파일에 Lock을 걸거나 푸는 System Call이다. 다음과 같은 Parameter를 이용한다.
  * fd - Open한 파일의 File Descriptor를 넣는다.
  * operation - fd에 대한 수행 동작 및 옵션을 명시한다. LOCK_SH, LOCK_EX, LOCK_UN 3가지 Operation을 넣을 수 있다. LOCK_SH은 Read Lock, LOCK_EX은 Write Lock, LOCK_UN은 Unlock 동작을 수행한다. 또한 LOCK_NB 옵션을 통해 Non-blocking System Call로 이용이 가능하다.
* Unlock은 LOCK_UN Operation을 이용하거나, fd가 **Close**되면 자동으로 Unlock된다. fd는 Application에서 명시적으로 Close함수를 통해서 fd를 호출하지 않더라도, Application이 종료되면 Kernel에서 fd를 Close한다. (fork 되지 않았다면) 따라서 flock System Call을 호출한 Application이 비정상적으로 종료되어도 파일에 걸린 Lock은 대부분의 경우 자연스럽게 Unlock 된다.
* 하지만 flock System Call을 호출한 Application이 fork System Call을 통해 다른 Application을 실행하는 경우, fork와 동시에 fd정보도 복사되기 때문에 flock System Call을 호출한 Application만 종료되면 fd는 Close 되지 않는다. 따라서 파일에 걸린 Lock이 풀리지 않게 되어 주의해야한다.

### 2. flock Tool

* Linux에서는 flock System Call을 이용하여 Shell에서 File Lock을 이용할 수 있는 flock Tool을 제공한다.

#### 2.1. Flow

![]({{site.baseurl}}/images/theory_analysis/flock_System_Call_Tool/flock_Tool_Flow.PNG)

* 위의 그림은 flock Tool의 실행 순서를 나타내고 있다. Open시 O_CREAT Option을 이용하기 때문에 Lock 파일이 없으면 Lock 파일이 생성된다. -x 옵션은 LOCK_EX 수행을 한다는 의미이고, Lock 파일은 file.lock 파일을 이용한다. /bin/bash가 Exclusive하게 수행된다.
* -o 옵션을 주면 flock Tool이 fork한 후 fd를 닫고 난뒤 Exclusive하게 Command를 수행한다. -o 옵션을 주지 않으면 fork 후 fd를 닫지 않기 때문에, flock Tool이 종료되어도 Command가 종료되지 않으면 fd는 Close되지 않는다. 따라서 파일 Lock이 풀리지 않을 수 있다. 반면 -o 옵션을 주면 Coomand에 관계 없이 flock Tool이 종료되는 순간 fd가 Close 되기 때문에 파일 Lock도 자연스럽게 풀린다. 하지만 Command 수행이 끝나지 않는 상태에서 파일 Lock이 풀릴 수 있기 때문에 Command가 Exclusive하게 수행되지 않을 수 있다.

#### 2.2. Lock File 삭제

![]({{site.baseurl}}/images/theory_analysis/flock_System_Call_Tool/Flock_Tool_File_Delete.PNG)

* flock Tool을 이용하면 Lock 파일이 생기게 되는데 이러한 Lock 파일을 외부에서 임의로 지우면 안된다. 위의 그림은 Lock 파일을 임의로 지우는 경우 Command가 Exclusive하게 동작하지 않을 수 있는 경우를 나타내고 있다. 첫번째 flock Tool이 수행되고 있을 때 2번째 flock Tool이 수행되면 같은 file.lock 파일을 Lock 파일로 이용하기 때문에 두번째 flock Tool은 Blocking된다. (빨간구간) 그 후 첫번째 flock Tool이 수행을 마치면서 두번째 flock Tool이 수행된다. 이때 세번째 flock Tool이 수행되기 전 file.lock이 지워지면, 두번째 flock Tool이 이용한 file.lock을 세번째 flock Tool이 볼 수 없기 때문에 Command가 동시에 실행될 수 있다.
* 이러한 Lock 파일 문제를 가장 쉽게 해결할 수 있는 첫번째 방법은 Lock 파일을 tmpfs같은 메모리 파일시스템에 만드는 방법이다. PC 재부팅 시 자연스럽게 Lock 파일은 지워진다. 두번째는 Lock 파일의 inode 번호까지 확인하는 별도의 Tool을 만드는 방법이 있다.

### 3. 참조

* inode Check File Lock - [http://stackoverflow.com/questions/17708885/flock-removing-locked-file-without-race-condition](http://stackoverflow.com/questions/17708885/flock-removing-locked-file-without-race-condition)
