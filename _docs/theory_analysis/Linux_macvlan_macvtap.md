---
title: Linux macvlan, macvtap
category: Theory, Analysis
date: 2017-10-29T12:00:00Z
lastmod: 2017-10-29T12:00:00Z
comment: true
adsense: true
---

Linux의 Virtual Network Device인 macvlan과 macvtap을 분석한다.

### 1. macvlan

![]({{site.baseurl}}/images/theory_analysis/Linux_macvlan_macvtap/macvlan_Component.PNG){: width="400px"}

macvlan은 하나의 Network Interface를 **여러개의 가상 Network Interface**로 분리하여 이용 할 수 있게 만드는 Network Device Driver이다. 위의 그림은 macvlan의 구성요소를 간략하게 나타내고 있다. macvlan은 Parent Inteface를 이용하여 여러개의 Child Interface를 생성한다. Child Interface는 각각 별도의 **MAC Address**와 **macvlan Mode**를 가질 수 있다. Mode는 Child Inteface 생성 시 설정 할 수 있으며, Mode에 따라 macvlan의 Packet 전송 정책이 달라진다. Mode에 따라서 Child Inteface간의 통신은 가능하지만, Mode에 관계없이 Parent Interface와 Child Interface는 서로 절대로 통신이 불가능한게 macvlan의 특징 중 하나이다.

![]({{site.baseurl}}/images/theory_analysis/Linux_macvlan_macvtap/macvlan_Example.PNG){: width="600px"}

위의 그림은 vlan Interface들을 macvlan의 Parent Interface로 두고 여러 Child Interface를 생성한 구성도를 나타내고 있다. macvlan은 물리 Ethernet Inteface 뿐만 아니라 vlan Interface, bridge Inteface 같은 가상의 Interface도 Parent Inteface로 둘 수 있다.

~~~
# ip li add link <parent> <child> type macvlan mode <mode (private, vepa, bridge, passthru)>
~~~

~~~
# ip li add link enp0s3 mac0 type macvlan mode private
# ip a
mac0@enp0s3: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN group default qlen 1
link/ether 4e:a4:2f:dc:75:8d brd ff:ff:ff:ff:ff:ff
~~~

macvlan은 위와 같은 ip 명령어를 통해 생성하고 확인 할 수 있다.

#### 1.1 Mac Address 관리

![]({{site.baseurl}}/images/theory_analysis/Linux_macvlan_macvtap/macvlan_Address_Manage.PNG){: width="700px"}

위의 그림은 macvlan Child의 Mac Address 관리 방법을 나타내고 있다. macvlan은 기본적으로 256 크기의 Hash Table과 Linked List를 이용하여 Child의 Mac Address를 관리한다. 그리고 이러한 Hash Table은 macvlan의 Parent Interface 개수만큼 생성된다. 위의 Example 그림에서 처럼 3개의 vlan Interface가 있다면 3개의 Hash Table이 Linux Kernel내에 존재하게 된다. 다시 말하면 macvlan Object는 Parent Interface 개수만큼 존재하고 각 macvlan Object는 하나의 Hash Table을 갖는다고 할 수 있다. Child Interface의 Mac Address는 Child Interface가 Up 될때 Hash Table에 등록되고, Child Interface가 Down될때 Hash Table에 등록된 Mac Address가 삭제된다.

#### 1.2. macvlan Mode

macvlan은 Child 생성시 각 Child에게 각각 다른 macvlan Mode를 설정 할 수 있다. Mode에 따라서 Packet 전송 정책이 달라진다. macvlan Mode는 Private Mode, VEPA Mode, Bridge Mode, Passthru Mode 4가지 Mode가 존재한다.

##### 1.2.1. Private Mode

![]({{site.baseurl}}/images/theory_analysis/Linux_macvlan_macvtap/macvlan_Private_Mode.PNG){: width="400px"}

위의 그림은 모든 Child가 Private Mode일때를 나타내고 있다. Packet이 Child에서 Parent로 나가는 경우 Child가 Private Mode라면, Packet은 무조건 Parent에게 전달된다. Packet이 Parent에서 Child로 들어오는 경우 Child의 Mode가 Private Mode라면, Packet의 Src Mac Address가 macvlan Hash Table에 있는지 검사한다. 만약 Src Mac Address가 Hash Table에 없다면 해당 Packet은 Child에게 전달되지만, 있다면 해당 Packet은 Drop된다. 이처럼 Private Mode는 동일 macvlan의 Child로 부터온 Packet을 받고 싶지 않을때 이용하는 Mode이다.

##### 1.2.2. VEPA (Virtual Ethernet Port Aggregator) Mode

![]({{site.baseurl}}/images/theory_analysis/Linux_macvlan_macvtap/macvlan_VEPA_Mode.PNG){: width="400px"}

위의 그림은 모든 Child가 VEPA Mode일때를 나타내고 있다. Packet이 Child에서 Parent로 나가는 경우 Child가 VEPA Mode라면, Packet은 무조건 Parent에게 전달된다. Packet이 Parent에서 Child로 들어오는 경우 Child의 Mode가 VEPA Mode라면, Packet은 Child에게 무조건 전달한다. 이처럼 VEPA Mode는 Child간의 통신을 허용하지만 Child에서 보낸 Packet이 무조건 Parent를 통해서 밖으로 전달되는 특징을 갖는다. Child로 부터온 전달된 Packet이 외부 스위치에 무조건 전달되야 할 경우 이용한다.

##### 1.2.3. Bridge Mode

![]({{site.baseurl}}/images/theory_analysis/Linux_macvlan_macvtap/macvlan_Bridge_Mode.PNG){: width="400px"}

위의 그림은 모든 Child가 Bridge Mode일때를 나타내고 있다. Packet이 Child에서 나가는 경우 Packet의 Dst Mac Address가 Hash Table에 존재한다면 macvlan은 해당 Packet을 Parent가 아닌 Child에게 바로 전달한다. Packet이 Parent에서 Child로 들어오는 경우 Child의 Mode가 Bridge Mode라면, Packet은 Child에게 무조건 전달한다. Linux Bridge와 동일한 동작을 수행하는 Mode이기 때문에 Linux Bridge를 대체하는 용도로 많이 이용된다.

##### 1.2.4. Passthru Mode

![]({{site.baseurl}}/images/theory_analysis/Linux_macvlan_macvtap/macvlan_Passthru_Mode.PNG){: width="200px"}

위의 그림은 Child가 Passthru Mode일때를 나타내고 있다. Passthru Mode의 Child는 무조건 Parent와 1:1 관계를 유지한다. 따라서 Child가 Passthru Mode인 경우에는 macvlan은 Hash Table을 이용하지 않는다. Passthru Mode는 일반적으로 macvlan에서는 이용되지 않고 macvtap을 통해 가상 머신에게 Virtual NIC을 제공 할 때 이용된다.

#### 1.3. vs Linux Bridge

macvlan의 Bridge Mode는 Linux Bridge를 대체 할 수 있다. Linux Bridge는 일반 물리 Bridge 처럼 Mac Learning을 통해서 Mac Table을 관리한다. 또한 STP (Spanning Tree Protocol)을 수행하여 Network 경로의 Loop를 방지한다. 반면에 macvlan은 Mac Learing을 수행하지 않고 단순히 Child가 Up/Down 될 때 Child Mac Address를 Hash Table에 등록/삭제만 한다. 또한 STP도 수행하지 않는다. 따라서 Linux Bridge에 비해서 CPU Overhead가 적은 편이고 이러한 적은 Overhead는 Packet 처리율 향상으로 이어진다. 따라서 Parent와 Child의 통신이 불필요하고 L2 Level의 단순한 Network를 구축하는 경우에는 macvlan을 이용하여 네트워크를 구축하는 것이 좋다.

### 2. macvtap

macvtap은 macvlan을 기반으로 Child Interface를 생성할 뿐만 아니라 /dev/tap* 형태의 Device 파일을 생성한다. User Application은 /dev/tap* 파일을 통해서 직접 Packet을 수신하거나, 전송 할 수 있다.

~~~
# ip li add link <parent> <child> type macvtap mode <mode (private, vepa, bridge, passthru)>
~~~

~~~
# ip li add link enp0s3 mac1 type macvtap mode private
# ip a
mac1@enp0s3: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN group default qlen 500
link/ether ee:38:97:8c:5d:5c brd ff:ff:ff:ff:ff:ff
# ls /dev/tap*
/dev/tap142
~~~

macvtap은 macvlan과 유사한 위의 명령어를 통해서 생성 할 수 있다. /dev/tap* 파일 생성도 확인 할 수 있다.

### 3. 참조

* macvlan code - [https://github.com/torvalds/linux/blob/80cee03bf1d626db0278271b505d7f5febb37bba/drivers/net/macvlan.c](https://github.com/torvalds/linux/blob/80cee03bf1d626db0278271b505d7f5febb37bba/drivers/net/macvlan.c)
* macvtap code - [https://github.com/torvalds/linux/blob/80cee03bf1d626db0278271b505d7f5febb37bba/drivers/net/macvtap.c](https://github.com/torvalds/linux/blob/80cee03bf1d626db0278271b505d7f5febb37bba/drivers/net/macvtap.c)
* macvlan - [https://hicu.be/bridge-vs-macvlan](https://hicu.be/bridge-vs-macvlan)
