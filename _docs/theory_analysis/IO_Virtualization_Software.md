---
title: I/O Virtualization Software
category: Theory, Analysis
date: 2017-03-31T12:00:00Z
lastmod: 2017-03-31T12:00:00Z
comment: true
adsense: true
---

하이퍼바이저의 I/O 가상화 기술 중 Software 가상화 기술을 분석한다.

### 1. Software I/O Virtualization

<img src="{{site.baseurl}}/images/theory_analysis/IO_Virtualization_Software/Software_IO_Virtualization.PNG" width="700px">

* Software I/O 가상화 기술은 **Emulation** 이다. 하이퍼바이저는 CPU의 하드웨어 기능을 이용하여(Intel VT-x, ARM Hypervisor Extension) 가상 머신 Kernel의 Device Driver가 I/O 요청 하는 순간 Exception을 발생시켜 하이퍼바이저가 실행되도록 설정한다. Exception이 발생하여 하이퍼바이저가 실행되면, 하이퍼바이저는 가상 머신이 어떤 I/O 동작을 하려고 했는지 파악하고 I/O Device Emulation을 수행 후 결과를 가상 머신에게 돌려준다. 가상 머신의 I/O는 Exception과 Emulation이라는 2가지 큰 오버헤드가 발생하기 때문에 가상 머신의 I/O 성능을 크게 낮추는 원인이 된다. 이러한 문제를 해결하기 위해 가상 머신 Device Driver를 원래 물리 머신에서 구동하는 Device Driver가 아닌, 가상 머신 전용 Device Driver를 이용하는 기법이 있다. 물리 머신의 Device Driver를 그대로 이용하는 방법을 I/O Full-virtualization이라고 하고, 가상 머신 전용 Device Driver를 이용하는 방법을 I/O Para-virtualization이라고 한다.

### 2. I/O Full-virtualization

* I/O Full-virtualization은 물리 머신의 Device Driver를 그대로 이용하는 방법을 의미한다. Linux에서 많이 이용되는 KVM+QEMU 조합에서 QEMU가 Device Emulation 역활을 수행한다.

<img src="{{site.baseurl}}/images/theory_analysis/IO_Virtualization_Software/KVM_QEMU_IO_Process.PNG" width="700px">

* 위의 그림은 KVM+QEMU에서 I/O Full-virtualization 처리 과정을 나타내고 있다. 그림에서 QEMU는 vCPU와 Event Loop라는 2개의 Thread를 이용하는걸 나타내고 있다. vCPU Thread가 Guest(가상 머신)의 Device Driver를 수행하다가 I/O 수행을 요청하면 Exception이 발생하여 Host(물리 머신)의 KVM Module이 수행된다. KVM Module은 QEMU에게 왜 Exception이 발생하였는지 이유를 전달한다. 전달받은 내용을 바탕으로 QEMU는 I/O 실제 Device에게 I/O 요청 한다. 처리가 끝나면 QEMU는 KVM Module에게 irqfd를 통해서 Guest에게 Virtual IRQ를 Inject 하도록 명령한다. Virtual IRQ를 받은 가상 머신은 자신이 요청한 I/O 처리가 완료되었다고 생각한다.

* 물리 머신에서 I/O 처리는 Application -> Device Driver -> Device -> 요청 완료 IRQ 발생 -> Device Driver -> Application의 순으로 진행된다. 가상 머신에서의 I/O 처리는 Device Drvier와 요청 완료 IRQ 사이에서 KVM+QEMU가 관여하여 Device Emulation을 수행하게 된다. 따라서 가상 머신은
자신이 이용하는 Device가 가상 Device인지 인식하지 못한다.

![]({{site.baseurl}}/images/theory_analysis/IO_Virtualization_Software/KVM_QEMU_Device.PNG)

* 위의 그림은 QEMU+KVM의 x86 가상 머신안에서 보이는 PCI 장치들을 나타내고 있다. QEMU는 NIC이나 HDD와 같은 장치 뿐만 아니라 PCI Bridge나 IDE Controller같은 x86 가상 머신 구동에 필수적인 모든 Device들을 Emulation한다.

### 3. I/O Para-virtualization


### 4. 참조
* QEMU - [http://blog.vmsplice.net/2011/03/qemu-internals-overall-architecture-and.html](http://blog.vmsplice.net/2011/03/qemu-internals-overall-architecture-and.html)
