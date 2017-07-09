---
title: Virtual Machine, Linux Container
category: Theory, Analysis
date: 2017-01-23T14:51:00Z
lastmod: 2017-01-23T14:51:00Z
comment: true
adsense: true
---

### 1. Virtual Machine(가상 머신)

![]({{site.baseurl}}/images/theory_analysis/Virtual_Machine_Linux_Container/Virtual_Machine.PNG){: width="500px"}

가상 머신은 실제 물리 자원이 아닌 **가상 자원**을 이용하는 머신을 의미한다. 가상 머신이 동작 할 수 있도록 가상 머신에게 가상 자원을 제공하고, 가상 머신을 관리하는 프로그램을 Hypervisor(Supervisor를 뛰어넘는) 또는 VMM(Virtual Machine Monitor)라고 부른다. 하이퍼바이저는 가상 머신에게 가상 CPU, 가상 Memory, 가상 Device라는 3가지의 종류의 가상 자원을 제공한다. 이렇게 가상 자원 위에서 동작하는 가상 머신은 특정 물리 머신에게 종속되지 않기 때문에 유연성을 갖는다. 이러한 유연성을 바탕으로 가상 머신은 IaaS의 기반 기술로 자리잡고 있다.

대부분의 서버에 이용되고 있는 x86 Archituecture의 CPU는 Hypervisor가 구동될 수 있는 Architecture의 조건 (Formal Requirements for Virtualizable Third Generation Architectures 논문의 조건)을 만족하지 못한다. 이러한 문제를 해결하기 위해 Intel의 경우에는 Vt-x Extension 기능을 제공한다. Hypervisor는 Vt-x Extension을 이용하여 가상 CPU나 가상 Memory를 큰 Overhead없이 가상 머신에게 제공한다. ARM Architecture에서도 비슷한 문제를 해결하기 위해 ARM Hypervisor Extension 기능을 제공한다.

문제는 가상 Device이다. 일반적인 Device는 하나의 System에서 독점적으로 이용하도록 설계되어 있다. 따라서 Hypervisor는 실제 Device를 제어하고 가상 머신에게는 Hypervisor가 가상 Device를 Emulation하여 제공한다. Linux에서 이용하는 KVM + QEMU Hypervisor 조합에서 QEMU가 이러한 Device Emulation 부분을 담당한다. Device를 Emulation 해야하기 때문에 가상 머신의 I/O 성능은 물리 머신에 비해서 크게 저하 된다. 이러한 Device Emulation Overhead를 줄이기 위해서 Para-virtualized Device Driver(VirtIO/Xen Split Device Driver Model)와 IOMMU, SR-IOV 같은 기술들이 이용되고 있다.

### 2. Linux Container

![]({{site.baseurl}}/images/theory_analysis/Virtual_Machine_Linux_Container/Linux_Container.PNG){: width="500px"}

Linux Container는 Linux Kernel에서 제공하는 가상화 기술이다. Linux에서 제공하는 Namespace와 Cgroup이라는 2가지 기능을 이용하여 Container를 생성한다. Container는 엄밀히 말하면 가상화 기술이기 보다는 **Isolation 기술**이라고 할 수 있다. 각 Container들은 격리된 공간에서 Application을 실행한다. Container들과 Host는 같은 Kernel을 공유한다. 따라서 각 Container는 오직 Host Kernel이 이용하는 물리 CPU, 물리 Memory, 물리 Device만을 이용할 수 있다. 또한 Container는 Ubuntu, CentOS 같은 Linux 기반 운영체제만을 이용 할 수 있다.

Linux Container는 Hypervisor가 제공하는 가상 CPU, 가상 Memory, 가상 Device를 이용하지 않고 실제 Host가 이용하는 물리 CPU, 물리 Memory, 물리 Device를 이용하는 구조이다. 따라서 Linux Container는 가상 자원을 구동하기 위한 Overhead가 거의 발생하지 않는다. Linux Container가 가상 머신에 비해서 Light-weight한 주요 이유이다. 하지만 Linux Container와 Host 사이의 Isolation이 완벽하지 않기 때문에, 현재 Cloud에서는 가상 머신 위에 Linux Container를 이용하는 방식으로 Host를 보호하고 있다.
