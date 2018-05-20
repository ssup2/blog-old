---
title: Formal Requirements for Virtualizable Third Generation Architectures
category: Paper, Patent
date: 2017-01-23T14:21:00Z
lastmod: 2017-01-23T14:21:00Z
comment: true
adsense: true
---

### 1. 요약

가상 머신(VM)과 하이퍼바이저(Hypervisor, VMM)를 정의하고 있는 최초의 논문이다. Instruction을 분류하고 하이퍼바이저가 구동되기 위한 CPU Architecture의 조건을 설명하고 있다.

### 2. 하이퍼바이저의 구성

하이퍼바이저는 기본적으로 **trap-and-emulation** 방식으로 동작한다. 가상 머신이 특정 리소스와 연관된 동작을 하려고 하면 Trap이 발생하여 하이퍼바이저가 실행되고, 하이퍼바이저는 Trap의 원인을 파악한후 적절한 Emulation을 통해 가상 머신이 실제 물리 머신에서 동작하는 듯한 착각을 하게 만든다. 따라서 하이퍼바이저는 다음과 같은 3가지 모듈로 구분할 수 있다.

* Dispatcher - Hardware Trap이 발생하면 실행되는 모듈. Allocator나 Interpreter를 실행한다.

* Allocator - 가상 머신의 요청에 따라서 Resource를 할당/해제하는 역활을 수행한다.

* Interpreter - Trap을 발생시키는 Instruction을 Emulation한다.

### 3. Instruction의 종류

* Privileged Instruction - User Mode에서 실행하는 경우 Trap이 발생하고, System Mode에서 실행하는 경우 Trap없이 실행하는 명령어를 의미한다.

* Control Sensitive Instruction - Resource의 설정을 바꾸는 명령어를 의미한다.

* Behavior Sensitive Instruction - Resource의 설정에 의존적인 명령어를 의미한다.

### 4. 하이퍼바이저를 동작시키기 위한 CPU Architecture의 종류

Resource를 설정하거나, Resource에 의존적인 Sensitive Instruction들은 모두 Privileged Instruction에 포함되어 있어야 한다. 몇몇의 Sensitive 명령어들이 Priviliged Instruction이 아니라면, 가상 머신이 해당 Priviliged Instruction을 통해서 Resource를 수정하거나 Resource에 의존적인 명령어를 수행할때 하이퍼바이저로 점프하는 Hardware Trap이 발생하지 않게 된다. Hardware Trap이 발생하지 않으면 하이퍼바이저는 실행되지 않기 때문에 가상 머신을 위한 적절한 Emulation을 수행하지 못한다.

x86, ARM Architecture의 몇몇 Sensitive Instruction이 Priviliged Instruction이 아니기 때문에 x86, ARM Architecture는 하이퍼바이저를 구동하기에 적합하지 않다. 이러한 문제를 해결하기 위해 Intel은 Intel-VTx라는 Extension을 추가하였고, ARM은 Hypervisor Extension을 추가하였다. 두 Extension 모두 Supervisor Mode 보다 아래 Level인 Hypervisor를 위한 Hypervisor Mode를 추가하였고, 가상 머신이 문제가 되던 Sensitive Instruction을 수행할 경우 Hypervisor가 구동되는 Hypervisor Mode로 Trap이 발생하도록 제작되었다.
