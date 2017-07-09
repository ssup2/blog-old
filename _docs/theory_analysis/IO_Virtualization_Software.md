---
title: I/O Virtualization Software
category: Theory, Analysis
date: 2017-03-31T12:00:00Z
lastmod: 2017-03-31T12:00:00Z
comment: true
adsense: true
---

Hypervisor의 I/O 가상화 기법 중 Software I/O 가상화 기법을 분석한다.

### 1. Software I/O Virtualization

![]({{site.baseurl}}/images/theory_analysis/IO_Virtualization_Software/Software_IO_Virtualization.PNG){: width="650px"}

Software I/O Virtualization은 **Emulation**을 기반으로 하는 기법이다. Hypervisor는 CPU의 하드웨어 기능을 이용하여(Intel VT-x, ARM Hypervisor Extension) 가상 머신의 Device Driver가 I/O 요청 하는 순간 Exception을 발생시켜 Hypervisor가 실행되도록 설정한다. Exception이 발생하여 Hypervisor가 실행되면, Hypervisor는 가상 머신이 어떤 I/O 동작을 하려고 했는지 파악하고 I/O Device Emulation을 수행 후 결과를 가상 머신에게 돌려준다. 가상 머신의 I/O는 Exception과 Emulation이라는 2가지 큰 Overhead가 발생하기 때문에 가상 머신의 I/O 성능을 크게 낮추는 원인이 된다. 이러한 문제를 해결하기 위해 가상 머신 Device Driver를 원래 물리 머신에서 구동하는 Device Driver가 아닌, 가상 머신 전용 Device Driver를 이용하는 기법이 있다. 물리 머신의 Device Driver를 그대로 이용하는 기법을 I/O Full-virtualization이라고 하고, 가상 머신 전용 Device Driver를 이용하는 기법을 I/O Para-virtualization이라고 한다.

### 2. I/O Full-virtualization

I/O Full-virtualization은 물리 머신의 Device Driver를 그대로 이용하는 기법을 의미한다. Linux에서 많이 이용되는 KVM+QEMU 조합에서 QEMU가 Device Emulation 역활을 수행한다.

![]({{site.baseurl}}/images/theory_analysis/IO_Virtualization_Software/KVM_QEMU_IO_Process.PNG){: width="650px"}

위의 그림은 KVM+QEMU에서 I/O Full-virtualization 처리 과정을 나타내고 있다. 그림에서 QEMU는 vCPU와 Main Loop라는 2개의 Thread를 이용하는걸 나타내고 있다. vCPU Thread가 Guest(가상 머신)의 Device Driver를 수행하다가 I/O 수행을 요청하면 Exception이 발생하여 Host(물리 머신)의 KVM Module이 수행된다. KVM Module은 QEMU에게 왜 Exception이 발생하였는지 이유를 전달한다. 전달받은 내용을 바탕으로 QEMU는 I/O 실제 Device에게 I/O 요청 한다. 처리가 끝나면 QEMU는 KVM Module에게 irqfd를 통해서 Guest에게 Virtual IRQ를 Inject 하도록 명령한다. Virtual IRQ를 받은 가상 머신은 자신이 요청한 I/O 처리가 완료되었다고 생각한다.

물리 머신에서 I/O 처리는 Application -> Device Driver -> Device -> 요청 완료 IRQ 발생 -> Device Driver -> Application의 순으로 진행된다. 가상 머신에서의 I/O 처리는 Device Drvier와 요청 완료 IRQ 사이에서 KVM+QEMU가 관여하여 Device Emulation을 수행하게 된다. 따라서 가상 머신은
자신이 이용하는 Device가 가상 Device인지 인식하지 못한다.

![]({{site.baseurl}}/images/theory_analysis/IO_Virtualization_Software/KVM_QEMU_Device.PNG)

위의 그림은 QEMU+KVM의 x86 가상 머신 안에서 보이는 PCI 장치들과 SCSI 장치들을 나타내고 있다. QEMU는 NIC이나 HDD와 같은 장치 뿐만 아니라 PCI Bridge나 IDE Controller같은 x86 가상 머신 구동에 필수적인 모든 Device들을 Emulation한다.

### 3. I/O Para-virtualization

I/O Para-virtualization은 가상 머신에서 물리 머신의 Device Driver를 이용하지 않고 **가상 머신 전용 Device Driver**를 이용하는 기법이다. I/O Full-virtualization의 처리 과정을 보면 가상 머신의 모든 I/O는 Device Emulation Layer(QEMU)를 거친다는 사실을 알 수 있다. Device Emulation 과정과 가상 머신과 Device Emulation Layer 사이의 I/O Data 전달 과정이 가상 머신의 I/O의 주요 Overhead가 된다는 의미이다. 가상 머신 전용 Device Driver는 이러한 Overhead들을 줄여 가상 머신의 I/O 성능을 향상 시키는 기법이다. KVM의 VirtIO, Xen의 Split Device Driver가 I/O Para-virtualization 기법에 해당한다.

가상 머신 전용 Device Driver는 가상 머신과 Device Emulation Layer 사이의 I/O Data 통신에 특화된 Device Driver이다. 가상 머신이 물리 머신 Device Driver를 이용 할 때 보다 Emulation Overhead는 줄어들고 가상 머신의 Exception도 덜 발생하게 된다. 따라서 I/O Para-virtualization 기법은 가상 머신의 I/O 성능 향상 뿐만 아니라 Emulation에 의한 Host의 CPU 사용률을 줄이는 효과도 가지고 있다.

#### 3.1. VirtIO

![]({{site.baseurl}}/images/theory_analysis/IO_Virtualization_Software/VirtIO_Architecture.PNG){: width="600px"}

위 그림은 VirtIO의 Architecture를 간략히 나타내고 있다. VirtIO는 크게 Frontend 부분인 VirtIO Driver, Backend 부분인 VirtIO Device Emulator 그리고 Frontend와 Backend를 연결해주는 Virtqueue 3가지로 구성되어 있다. Virio Driver는 가상 머신의 Kernel에 탑재되는 Device Driver이다. Virito Device Driver에는 여러가지가 있는데, 대표적으로 Network를 위한 virito-net과 Block 장치를 위한 virtio-Blk, virtio-scsi가 있다. VirtIO Device Emulator는 QEMU가 담당한다. Virtqueue는 가상 머신과 QEMU의 공유 메모리에 위치하여 Frontend와 Backend사이에서 가상 머신의 I/O Data를 전달하는 역활을 수행한다.

![]({{site.baseurl}}/images/theory_analysis/IO_Virtualization_Software/KVM_QEMU_virtIO_Process.PNG){: width="650px"}

위의 그림은 KVM+QEMU+VirtIO에서 I/O Para-virtualization 처리 과정을 나타내고 있다. 가상 머신은 VirtIO Device Drvier를 통해 I/O를 요청한다. VirtIO Device Driver는 Kick이라는 동작을 통해 Exception을 발생시켜 KVM을 깨운다. KVM은 다시 ioeventfd를 이용하여 QEMU의 Main Loop을 깨운다. 깨어난 QEMU는 VirtIO Queue에 있는 I/O Data를 실제 I/O Device에 Write하고 그 응답을 다시 Virtqueue에 Write한다. 그 후 QEMU는 KVM Module에게 irqfd를 통해서 Guest에게 Virtual IRQ를 Inject 하도록 명령하여 가상 머신의 I/O 처리를 끝낸다.

![]({{site.baseurl}}/images/theory_analysis/IO_Virtualization_Software/KVM_QEMU_virtIO_Device_Blk.PNG)

![]({{site.baseurl}}/images/theory_analysis/IO_Virtualization_Software/KVM_QEMU_virtIO_Device_SCSI.PNG)

위의 그림들은 QEMU+KVM+Virtio의 x86 가상 머신 안에서 보이는 PCI 장치들과 SCSI 장치들을 나타내고 있다. PCI 장치에 VirtIO 장치들이 있는걸 확인 할 수 있다. virtio-scsi의 경우 SCSI 장치로도 인식되는걸 확인 할 수 있다.

#### 3.2. vhost

vhost는 QEMU의 Virtio Device Emulation 역활을 수행하는 **Kernel Module**이다. 지금까지 설명한 가상 머신의 I/O 처리 과정을 보면, 가상 머신의 Exception 뿐만 아니라 KVM <-> QEMU, QEMU <-> Host Device Driver 사이의 많은 CPU Mode Switch가 발생하는 것을 알 수 있다. 이러한 Mode Switch Overhead를 줄이기 위해서 vhost는 Virtio Device Emulation을 Kernel Module에서 수행한다.

또한 QEMU는 Global Mutex를 통해 Device Emulation 과정을 Serialization하기 때문에 가상 머신이 동시에 많은 I/O 요청을 수행하면 I/O 성능이 크게 떨어지는 단점을 가지고 있다. vhost를 이용하면 QEMU의 Global Mutex를 벗어나 VirtIO Device Emulation을 수행하기 때문에 VirtIO의 성능 향상 효과도 가져온다.

![]({{site.baseurl}}/images/theory_analysis/IO_Virtualization_Software/KVM_QEMU_virtIO_vhostnet_Progress.PNG){: width="650px"}

![]({{site.baseurl}}/images/theory_analysis/IO_Virtualization_Software/KVM_QEMU_virtIO_vhostscsi_Progress.PNG){: width="650px"}

위의 그림들은 KVM+QEMU+VirtIO+vhost에서 I/O Para-virtualization 처리 과정을 나타내고 있다. QEMU대신 vhost가 VirtIO Device Emulation 역활을 수행하는 것을 알 수 있다. 나머지 과정은 VirtIO만을 이용 할 때와 동일하다. vhost-net은 virtio-net의 Emulation 역활을 수행하고, vhost-scsi+LIO가 virtio-scsi의 Emulation 역활을 수행한다.

![]({{site.baseurl}}/images/theory_analysis/IO_Virtualization_Software/KVM_QEMU_virtIO_vhost_Device.PNG)

위의 그림들은 QEMU+KVM+Virtio+vhost의 x86 가상 머신 안에서 보이는 PCI 장치들과 SCSI 장치들을 나타내고 있다. SCSI 장치에 LIO를 인식하는걸 확인 할 수 있다.

### 4. 참조
* QEMU - [http://blog.vmsplice.net/2011/03/qemu-internals-overall-architecture-and.html](http://blog.vmsplice.net/2011/03/qemu-internals-overall-architecture-and.html)
