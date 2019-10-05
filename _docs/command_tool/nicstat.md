---
title: nicstat
category: Command, Tool
date: 2019-09-16T12:00:00Z
lastmod: 2019-09-16T12:00:00Z
comment: true
adsense: true
---

NIC의 통계 정보를 출력하는 nicstat의 사용법을 정리한다.

***

* TOC
{:toc}

***

### 1. nicstat

#### 1.1. # nicstat

{% highlight console %}
# nicstat
    Time      Int   rKB/s   wKB/s   rPk/s   wPk/s    rAvs    wAvs %Util    Sat
15:13:34  docker0    0.00    0.00    0.00    0.00    0.00   71.78  0.00   0.00
15:13:34     eth0    2.18    0.08    2.22    0.91  1007.5   86.86  0.00   0.00
15:13:34       lo    0.83    0.83    0.90    0.90   937.9   937.9  0.00   0.00
{% endhighlight %}
<figure>
<figcaption class="caption">[Shell 1] nicstat</figcaption>
</figure>

모든 NIC의 통계 정보를 출력한다. [Shell 1]은 "nicstat"을 이용하여 모든 NIC의 통계 정보를 출력하는 Shell의 모습을 나타내고 있다. 각 열은 다음과 같은 의미를 나타낸다.

* rKB/s : 초당 수신하는 Data의 양을 KB으로 나타낸다.
* wKB/s : 초당 송신하는 Data의 양을 KB으로 나타낸다. 
* rPk/s : 초당 수신하는 Packet의 개수를 나타낸다.
* wPk/s : 초당 송신하는 Packet의 개수를 나타낸다.
* rAvs : 수신하는 평균 Packet의 크기를 나타낸다.
* wAvs : 송싱하는 평균 Packet의 크기를 나타낸다.
* %Util : 송수신 Bandwidth 사용률을 나타낸다.
* Sat : 초당 발생한 Error의 개수를 나타낸다. -x 옵션을 통해서 상세하게 확인 가능하다.

#### 1.2. # nicstat -U

{% highlight console %}
# nicstat -U
    Time      Int   rKB/s   wKB/s   rPk/s   wPk/s    rAvs    wAvs %rUtil %wUtil
12:23:34  docker0    0.00    0.00    0.00    0.00    0.00   71.78   0.00   0.00
12:23:34     eth0    2.64    0.09    2.53    1.04  1067.3   84.93   0.00   0.00
12:23:34       lo    0.83    0.83    0.90    0.90   940.4   940.4   0.00   0.00
{% endhighlight %}
<figure>
<figcaption class="caption">[Shell 2] nicstat -U</figcaption>
</figure>

%Util을 %rUtil(수신 Util, Read Util)과 %wUtil(송신 Util, Write Util)로 분리하여 출력한다. [Shell 2]는 "nicstat -U"를 이용하여 %rUtil, %wUtil을 분리하여 출력하는 Shell의 모습을 나타내고 있다. 나머지는 [Shell 1]과 동일하다.

#### 1.3. # nicstat -x

{% highlight console %}
# nicstat -x  
12:25:57      RdKB    WrKB   RdPkt   WrPkt   IErr  OErr  Coll  NoCP Defer  %Util
docker0       0.00    0.00    0.00    0.00   0.00  0.00  0.00  0.00  0.00   0.00
eth0          2.63    0.09    2.53    1.04   0.00  0.00  0.00  0.00  0.00   0.00
lo            0.83    0.83    0.90    0.90   0.00  0.00  0.00  0.00  0.00   0.00
{% endhighlight %}
<figure>
<figcaption class="caption">[Shell 3] nicstat -x</figcaption>
</figure>

모든 NIC의 확장된 통계 정보를 출력한다. [Shell 3]는 "nicstat -x"를 이용하여 모든 NIC의 확장된 통계 정보를 출력하는 Shell의 모습을 나타내고 있다. 각 열은 다음과 같은 의미를 나타낸다.

* RdKB : 초당 수신하는 Data의 양을 KB으로 나타낸다.
* WrKB : 초당 송신하는 Data의 양을 KB으로 나타낸다. 
* RdPkt : 초당 수신하는 Packet의 개수를 나타낸다.
* WrPkt : 초당 송신하는 Packet의 개수를 나타낸다.
* IErr : 수신한 Packet의 Error 때문에 처리하지 않은 Packet의 개수를 나타낸다.
* OErr : 송신전에 Error 때문에 송신하지 않은 Packet의 개수를 나타낸다.
* Coll : Ethernet Collision이 발생한 횟수를 나타낸다.
* NoCP : Packet을 수신해야할 Process가 너무 바빠 Packet을 처리하지 못하여, 수신된 Packet이 해당 Process에 전달되지 못한 횟수를 나타낸다.
* Defer : 전송 매체가 바빠서 전송이 지연된 횟수를 나타낸다.
* %Util : 송수신 Bandwidth 사용률을 나타낸다.

#### 1.4. # nicstat -i [Interface]

[Interface] NIC의 통계 정보만 출력한다.

#### 1.5. # nicstat -i [Interface] [Interval] [Count]

[Interface] NIC의 통계 정보를 [Interval] 간격으로 [Count]만큼 반복한다.
