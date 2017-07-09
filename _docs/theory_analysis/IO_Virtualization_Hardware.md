---
title: I/O Virtualization Hardware
category: Theory, Analysis
date: 2017-04-09T12:00:00Z
lastmod: 2017-04-09T12:00:00Z
comment: true
adsense: true
---

Hypervisor의 I/O 가상화 기법 중 Hardware I/O 가상화 기법을 분석한다.

### 1. Hardware I/O Virtualization

Hardware I/O Virtualization 기법은 이름 그대로 Hardware 기능의 도움을 받아 가상 머신이 이용하는 I/O Device를 가상화 하는 기법이다. I/O Software 가상화 기법은 Device Emulation 과정과 I/O Data 전달 과정에 의한 Overhead 때문에 물리 머신에 비해 큰 I/O 성능 저하가 나타나게 된다. Hardware I/O Virtualization 기법은 Device Emulation과 I/O Data 전달을 Hardware의 기능을 이용하여 수행하기 때문에 가상 머신의 I/O 성능 감소가 거의 없다는 장점이 있다.

I/O Data 전달은 CPU의 **IOMMU** 기능을 통해 수행한다. Device Emulation 과정은 I/O Device의 **SR-IOV (Single Root IO Virtualization)** 기능을 통해 수행한다. 현재 나오는 대부분의 CPU는 IOMMU기능이 포함되어 있다. 하지만 SR-IOV가 적용된 I/O Device의 가격은 일반 I/O Device에 비해서 현재 가격이 많이 높은 편이다.

### 2. IOMMU

![]({{site.baseurl}}/images/theory_analysis/IO_Virtualization_Hardware/IOMMU.PNG){: width="650px"}

CPU의 IOMMU를 통해 Hypervisor의 간섭 없이 가상 머신은 I/O Device와 I/O Data를 직접 주고 받을 수 있다. 위의 그림은 IOMMU의 역활을 간략하게 나타내고 있다. Intel의 Vt-d이 IOMMU를 기반으로한 기법이다.

![]({{site.baseurl}}/images/theory_analysis/IO_Virtualization_Hardware/IOMMU_MMU_Flow.PNG){: width="650px"}

IOMMU는 MMU와 다른 역활을 수행한다. MMU는 CPU에서 보는 Memory 주소를 변환하는 장치이다. IOMMU는 I/O Device가 보는 Memory 주소를 변환하는 장치이다. 위의 그림은 MMU와 IOMMU를 통해 CPU와 I/O Device가 보는 Memory 주소가 변환되는 과정을 나타내고 있다. MMU는 CPU Core에 위치하여 Memory 주소를 변환한다. 반면 IOMMU는 CPU의 North-Bridge에 위차하여 I/O Device가 보는 Memory 주소를 변환한다.

![]({{site.baseurl}}/images/theory_analysis/IO_Virtualization_Hardware/IOMMU_Page_Walk.PNG)

위의 그림은 IOMMU의 Memory 주소 변환 과정을 나타내고 있다. PCI Device는 Device Number와 Function Number 2가지를 가지고 있다. 하나의 PCI Device는 여러개의 Function을 가질 수 있다. 일반 User 입장에서는 하나의 Function이 하나의 PCI Device로 인식하게 된다. IOMMU 주소 변환 과정을 보면 Device Number + Function Number로 한번 Page Walk를 수행하고, Memory 주소를 통해 한번 더 Page Walk를 수행하는 **2단계 Page Walk**를 이용한다. IOMMU는 CPU에 한개가 존재하지만 실제로 각 PCI Device Function마다 서로 다른 Memory 주소를 볼 수 있도록 설정이 가능하다는 의미이다.

가상 머신이 이용하는 Memory는 실제 물리 Memory 주소가 아니라 Hyervisor가 제공하는 가상 Memory 주소를 이용한다. 운영체제가 각 Process들에게 CPU의 MMU를 통하여 물리 Memory 주소가 아닌 가상 Memory 주소를 이용하도록 만드는것과 같은 원리이다. 일반적으로 Hypervisor가 이용되는 환경에서 Hypervisor가 이용하는 실제 물리 Memory 주소를 Host Address, 가상 머신이 이용하는 가상의 Memory 주소를 Pysical Address, 가상 머신의 Process가 이용하는 Memory 주소를 Virtual Address라고 표현한다.

가상 머신은 자신이 이용하는 Memory 주소가 가상화된 Memory 주소라는걸 인식하지 못한다. 따라서 가상 머신은 I/O Device의 DMA(Direct Access Memory) Conroller 설정 시 가상 머신이 보고 있는 Physical Address를 기준으로 DMA 주소를 설정한다. 문제는 I/O Device의 DMA Controller는 기본적으로 실제 물리 주소인 Host Address를 기준으로 DMA를 수행한다는 점이다. 이러한 문제를 해결하기 위해서 IOMMU를 이용한다. Hyperivosr는 IOMMU를 이용하여 I/O Device의 DMA Conroller가 가상 머신이 보는 Physical Address를 볼 수 있도록 설정한다.

I/O Device의 DMA Conroller가 IOMMU를 통해서 가상 머신의 Physical Address를 보게 되면, I/O Device Data는 DMA를 통해 바로 가상 머신에게 전달되기 때문에 Hypervisor는 I/O Device Data 전달을 간섭하지 못한다. 다시 말해 이러한 IOMMU 설정 과정은 I/O Device를 특정 가상 머신만 이용할 수 있도록 **할당** 하는 과정이라고 할 수 있다. IOMMU는 PCI Device Function마다 다른 Memory 주소를 볼 수 있도록 설정 가능하기 때문에, Hypervisor가 인식할 수 있는 PCI Device Function들은 각기 다른 가상 머신에게 할당 할 수 있다.

IOMMU릍 이용하여 가상 머신과 I/O Device간의 I/O Data 전달을 Hypervisor의 간섭 없이 수행 할 수 있게는 할 수는 있지만, I/O Interrupt 경우 Hyperivsor가 먼져 받은 후 다시 해당 가상 머신의 vCPU에게 전달 해야 한다. I/O Interrupt를 바로 해당 가상 머신에게 전달하는 기법이 있지만 제약 사항이 많아, 대부분의 Hyervisor에서 이용하지 않고 있다.

### 3. SR-IOV (Single Root IO Virtualization)

![]({{site.baseurl}}/images/theory_analysis/IO_Virtualization_Hardware/SR-IOV.PNG){: width="450px"}

하나의 I/O Device를 Host에게 **여러개의 I/O Device**처럼 보이게 하는 가상화 기법이다. 위의 그림은 SR-IOV Device의 구성도를 간략하게 나타내고 있다. SR-IOV Device는 하나의 PF(Physical Function)와 여러개의 VF(Virtual Function)로 구성되어 있다. 일반적인 Device의 경우 PF만 존재하고 VF는 존재하지 않는다. 각 VF를 Hypervisor 입장에서는 여러개의 I/O Device처럼 이용할 수 있다.

### 4. IOMMU + SR-IOV Device

![]({{site.baseurl}}/images/theory_analysis/IO_Virtualization_Hardware/SR-IOV+IOMMU.PNG){: width="650px"}

위의 그림은 IOMMU + SR-IOV를 이용하여 Hardware I/O 가상화 기법을 나타내고 있다. Hypervisor는 SR-IOV를 통해서 하나의 I/O Device를 여러개의 I/O Device처럼 이용 할 수 있게 된다. SR-IOV를 통해 가상화된 I/O Device(VF)는 IOMMU를 통해서 각 VM에게 할당된다. 가상 머신이 I/O 수행시 Hyperivsor는 I/O Device의 Interrupt만 가상 머신에게 전달해 주면 된다.

SR-IOV Device의 PF와 VF들에게 IOMMU를 적용하지 않고, Software I/O 가상화 기법을 이용하여 한번더 가상화 하여 가상 머신들에게 제공할 수도 있다.
