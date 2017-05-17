---
title: Barrier
category: Theory, Analysis
date: 2017-01-25T00:34:00Z
lastmod: 2017-01-25T00:34:00Z
comment: true
adsense: true
---

### 1. 정의

병렬 프로그래밍의 동기화 기법중 하나이다. Process/Thread 그룹에서 어느 한 Process/Thread가 특정 Barrier에 도달한 경우, 다른 모든 Process/Thread가 해당 Barrier에 도달 할 때까지 Blocking 된다. 그 후 모든 Process/Thread가 해당 Barrier에 도달하면 다음 명령어를 수행한다. Barrier는 Process/Thread의 흐름을 제어하는 기법이라고 할 수 있다.

Compiler는 최적화를 진행하면서 명령어의 순서를 바꾸기도 하는데, Barrier를 통해 이러한 Compiler의 Reorering 기법을 막을 수 있다.

### 2. 예제

> A -> B -> C -> D -> E

위와 같이 알파벳 순서대로 명령어를 수행하도록 Coding이 되어 있어도 Compiler는 최적화를 통해 명령어 수행 순서를 바꿀 수 있다. 만약 하드웨어 특성상 A 명령어는 반드시 C 명령어보다 먼져 실행되어야 한다고 가정해보자. 컴파일러는 이러한 하드웨어 특성을 알지 못하고 Reordering을 통해 A 명령어와 C 명령어의 수행 순서를 바꿀 수 있다.

> A -> [Barrier] -> B -> C -> D -> E

위와 같이 A 명령어와 B 명령어 사이에 Barrier를 넣으면 특정 Process/Thread 그룹안에 있는 모든 Process/Thread들이 A 명령어를 실행한 뒤 B 명령어를 수행하게 된다. A 명령어와 C 명령어 사이에 Barrier가 있기 때문에  Compier는 A 명령어와 C 명령어의 수행 순서를 바꿀 수 없게 된다.

### 3. 참조

* [https://en.wikipedia.org/wiki/Barrier_(computer_scienc)](https://en.wikipedia.org/wiki/Barrier_(computer_science))
* [http://forum.falinux.com/zbxe/index.php?document_srl=534002&mid=Kernel_API](http://forum.falinux.com/zbxe/index.php?document_srl=534002&mid=Kernel_API)
