---
title: KVM, QEMU
category: Theory, Analysis
date: 2017-01-20T15:49:00Z
lastmod: 2017-01-22T15:49:00Z
comment: true
adsense: true
---

리눅스에서 Hypervisor로 이용되고 있는 KVM, QEMU에 관하여 분석한다.

### 1. KVM (Kernel-based Virtual Machine)

Linux에서 제공하는 Type 1 Hypervisor이다. Linux가 설치되어 있고 Host PC(물리 PC)의 CPU가 하드웨어 가상화 기능을 지원하면 이용할 수 있다. 개인용 PC나 서버에서 이용되는 대부분의 x86 CPU들은 VT-x, VT-d같은 하드웨어 가상화 기능을 지원하기 때문에 리눅스만 설치되어 있다면 쉽게 KVM 설치 및 이용할 수 있다. 하지만 KVM만으로는 가상 머신을 구동 할 수 없다. KVM은 오직 가상 머신이 이용하는 **vCPU(Virtual CPU)**와 **Memory**만을 제공하기 때문이다. 가상 머신이 구동되기 위해서는 vCPU, Memory 뿐만 아니라 HDD, Monitor와 같은 주변 장치도 필요하고, 주변 장치와 CPU를 연결해주는 PCI BUS 등도 필요하다. 이러한 주변 장치와 PCI BUS를 VM에게 제공해주는 것이 QEMU이다.

### 2. QEMU

QEMU는 **Emulator**이다. QEMU는 vCPU부터 주변 장치까지 다양한 가상의 장치들을 Emulation하여 생성한다. KVM은 QEMU가 생성한 PCI Bus, 주변 장치등을 가상 머신에게 할당하여 가상 머신을 구동한다. Xen에서도 KVM과 동일하게 QEMU가 생성한 PCI Bus, 주변 장치등을 가상 머신에게 할당하여 가상 머신을 구동한다. QEMU는 vCPU도 Emulation 할 수 있기 때문에 KVM이나 XEN 없이도 가상 머신을 구동 할 수 있다. 하지만 vCPU Emulation Overhead와 QEMU Architecture의 특징 때문에, QEMU만을 이용하여 가상 머신을 구동하면 가상 머신의 성능이 매우 낮아진다. 따라서 KVM + QEMU의 조합으로 가상 머신을 구동하는것이 좋다.

#### 2.1. QEMU Architecture

QEMU의 Architecture는 Parallel Architecture와 Event-Driven Architecture의 결함인 Hybrid Architecture를 선택하고 있다. Parallel Achitecture는 어떤 요청에 대한 처리가 있을때 마다 Thread를 생성하여 병렬적으로 처리하는 Architecture이다. 요청에 대한 반응성은 좋지만 Thread의 개수가 늘어날 수록 Context Switching Overhead가 커지기 때문에, 전체적인 성능이 떨어진게 된다. 반대로 Event-Driven Architecture는 하나의 Main Loop Thread가 돌면서 Event 발생을 검사하고 발생한 Event가 있으면 해당 Event의 Event Handler를 수행시키는 구조이다. 하나의 Thread만을 이용하기 때문에 Context Switching Overhead가 적다는 장점을 가지고 있지만, Event Handler에서의 Event 처리시간이 길어지면 전반직인 Event의 반응성이 크게 떨어진다는 단점을 가지고 있다.

QEMU는 하나의 Main Loop Thread에서 대부분의 Event 및 관련 연산를 처리하고, CPU Intensive한 처리는 별도의 Worker Thread에 할당하여 처리한다. Main Loop Thread에서는 File Descriptor를 이용하여 Event를 확인하고 처리한다. Worker Thread는 할당받은 일의 처리가 완료되면 Main Loop Thread에 처리 완료 Event를 전달하고 종료한다. QEMU는 가상 머신이 이용하는 vCPU 처리를 Main Loop Thread에서 처리하는 방식과 별도의 Thread에서 처리하는 방식 2가지를 선택할 수 있는데, 전자의 방식을 non-iothread 처리 방식이라고 하고 후자의 방식을 iothread를 이용하는 처리 방식이라고 한다.

##### 2.1.1. QEMU with non-iothread

![[그림 1] non-iothread를 이용하는 QEMU 구조]({{site.baseurl}}/images/theory_analysis/KVM_QEMU/QEMU_non-iothread.PNG)

non-iothread 방식은 Main Loop Thread에서 vCPU 처리와 Event를 같이 처리한다. 즉 하나의 Thread에서 vCPU 처리와 대부분의 주변 장치 Emulation을 같이하는 구조이다. TCG는 vCPU를 Emulation하는 QEMU의 모듈이다. [그림 1]처럼 가상 머신의 2개의 vCPU를 가지고 있더라도 Main Loop Thread에서만 Multiplexing되어 처리되기 때문에, 가상 머신이 여러개의 vCPU를 가지고 있더라도 실제로는 병렬적으로 처리되지 않는다. 따라서 non-iothread 구조의 가상 머신은 매우 느릴수 밖에 없다. 초기 QEMU의 Architecture이다.

##### 2.1.2. QEMU with iothread

![[그림 2] iothred를 이용하는 QEMU 구조]({{site.baseurl}}/images/theory_analysis/KVM_QEMU/QEMU_iothread.PNG)

iothread 방식은 Main Loop Thread에서는 Event만 처리하고 각 vCPU마다 Thread를 할당하여 처리하는 방식이다. Main Loop Thread뿐만 아니라 모든 vCPU Thread에서도 주변 장치 Emulation을 수행한다. 다수의 Thread를 이용하기 때문에 iothread 방식에서는 주변 장치 Emulation 과정이 병렬로 처리되는것 처럼 보인다. 하지만 QEMU의 주변 장치 Emulation Code는 대부분 Thread Safe하게 작성되어 있지 않기 때문에 Global Mutex를 이용하여 Serialization 되어 있고, 이에 따라 병렬로 처리되지 않는다. 이러한 주변 장치 Emulation의 Serialization은 가상 머신의 I/O 성능을 떨어트리는 주요 원인중 하나이다.

vCPU도 상황은 비슷하다. vCPU들이 별도의 Thread를 이용하기 때문에 병렬적으로 처리된는 것처럼 보이지만 실제로 vCPU를 Emulating하는 TCG의 Achitecture 때문에 vCPU의 병렬 처리율이 매우 낮다고 한다. 따라서 iothread만 이용하는 방식 또한 가상 머신의 빠른 성능을 얻기에는 힘든 구조이다.

##### 2.1.3. QEMU with iothread and KVM

![[그림 3] iothread, KVM을 이용하는 QEMU 구조]({{site.baseurl}}/images/theory_analysis/KVM_QEMU/QEMU_KVM.PNG)

iothread 방식에서 TCG대신 KVM을 이용하여 vCPU를 구동하는 방법이다. 주변 장치 Emulation의 Serialization 문제는 여전히 갖고 있지만, KVM에 의해서 각 vCPU는 병렬로 처리된다. 이러한 이유 때문에 SMP 가상 머신을 제대로 지원하기 위해서는 QEMU + KVM을 이용해야 한다.

### 3. 참조

QEMU : [http://blog.vmsplice.net/2011/03/qemu-internals-overall-architecture-and.html](http://blog.vmsplice.net/2011/03/qemu-internals-overall-architecture-and.html)
