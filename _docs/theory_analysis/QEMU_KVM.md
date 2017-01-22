---
title: KVM, QEMU
category: Language
date: 2017-01-22T15:31:00.000Z
lastmod: 2016-01-22T15:31:00.000Z
comment: true
adsense: true
---

리눅스에서 하이퍼바이저로 이용되고 있는 KVM, QEMU에 관하여 분석한다.

### 1. KVM (Kernel-based Virtual Machine)

* Linux에서 제공하는 Type 1 하이퍼바이저이다. Linux가 설치되어 있고 Host PC(물리 PC)의 CPU가 하드웨어 가상화 기능을 지원하면 이용할 수 있다. 개인용 PC나 서버에서 이용되는 대부분의 x86 CPU들은 VT-x, VT-d같은 하드웨어 가상화 기능을 지원하기 때문에 리눅스만 설치되어 있다면 쉽게 KVM 설치 및 이용할 수 있다. 하지만 KVM만으로는 가상 머신을 구동 할 수 없다. KVM은 오직 가상 머신이 이용하는 **vCPU(Virtual CPU)**와 **Memory**만을 제공하기 때문이다. 가상 머신이 구동되기 위해서는 vCPU, Memory 뿐만 아니라 HDD, Monitor 같은 주변 장치 뿐만 아니라 주변 장치와 CPU를 연결해주는 PCI BUS도 필요하기 때문이다. 이러한 주변 장치와 PCI BUS 기능을 제공해주는 것이 QEMU이다.

### 2. QEMU

* QEMU는 **Emulator**이다. 가상의 CPU부터 주변 장치까지 다양한 장치들을 생성하고 Emulating 한다. 따라서 QEMU를 이용하면 x86 PC에서 ARM용으로 Compile된 프로그램도 돌릴 수 있다 (KVM은 불가능). **QEMU는 KVM이 제공하지 못하는 가상의 주변 장치와 PCI BUS를 가상 머신에게 제공할 수 있다.** 따라서 KVM은 QEMU을 이용하여 가상 머신을 구동한다. 물론 QEMU만으로 가상 머신을 구동할 수 있다. 하지만 vCPU Emulating Overhead와 QEMU Arhictecture의 특징때문에 QEMU만을 이용하여 가상 머신을 구동하면 가상 머신의 성능이 매우 낮아진다. 따라서 KVM + QEMU의 조합으로 가상 머신을 구동하는것이 좋다. XEN도 QEMU를 이용하여 가상 머신에게 가상의 주변장치와 PCI BUS를 제공한다.

#### 2.1. QEMU Architecture

* QEMU의 Architecture는 Parallel Architecture와 Event-Driven Architecture의 결함인 Hybrid Architecture를 선택하고 있다. Parallel Achitecture는 어떤 요청에 대한 처리가 있을때 마다 Thread를 생성하여 병렬적으로 처리하는 Architecture이다. 요청에 대한 반응성은 좋지만 Thread의 개수가 늘어날 수록 Context Switching Overhead가 커지기 때문에, 전체적인 성능이 떨어진게 된다. 반대로 Event-Driven Architecture는 하나의 Main Loop(Thread)가 돌면서 Event 발생을 검사하고 발생한 Event가 있으면 해당 Event의 Event Handler를 수행시키는 구조이다. 하나의 Thread만을 이용하기 때문에 Context Switching Overhead가 적다는 장점을 가지고 있지만, Event Handler에서의 Event 처리시간이 길어지면 전반직인 Event의 반응성이 크게 떨어진다는 단점을 가지고 있다. 

* QEMU는 하나의 Main Loop에서 대부분의 Event 및 관련 연산를 처리하고, CPU Intensive한 처리는 별도의 Worker Thread에 할당하여 처리한다. Main Loop에서는 File Descriptor를 이용하여 이벤트를 확인하고 처리한다. Worker Thread는 할당받은 일의 처리가 완료되면 Main Loop에 처리 완료 이벤트를 전달하고 종료한다. 

* QEMU는 가상 머신이 이용하는 vCPU 처리를 Main Loop에서 처리하는 방식과 별도의 Thread에서 처리하는 방식 2가지를 선택할 수 있는데, 전자의 방식을 non-iothread 처리 방식이라고 부르고 후자의 방식을 iothread를 이용하는 처리 방식이라고 부른다.



출처: http://ssup2.tistory.com/entry/KVM-QEMU [썹이의 블로그]

