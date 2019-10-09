---
title: iftop
category: Command, Tool
date: 2019-10-09T12:00:00Z
lastmod: 2019-10-09T12:00:00Z
comment: true
adsense: true
---

특정 Interface의 Network Bandwidth 사용량을 Src IP/Dst IP로 분류한 다음, 샤용량이 높은 순서에 따라서 출력하는 iftop을 분석한다.

***

* TOC
{:toc}

***

### 1. iftop

#### 1.1. # iftop -i [Interface]

{% highlight console %}
 Press H or ? for help            25.0Kb            37.5Kb           50.0Kb      62.5Kb
└─┴─┴─┴─┴──
node09                        => dns.google                      672b   1.11Kb  1.05Kb
                              <=                                 672b   1.00Kb  1.04Kb
node09                        => 192.168.0.40 cast.net             0b      0b    931b
                              <=                                   0b      0b   3.33Kb
_gateway                      => all-systems.mcast.net             0b      0b     34b
                              <=                                   0b      0b      0b
node09                        => 106.247.248.106                   0b      0b     15b
                              <=                                   0b      0b     15b
node09                        => dadns.cdnetworks.co.kr            0b      0b     15b
                              <=                                   0b      0b     15b
node09                        => ch-ntp01.10g.ch                   0b      0b     15b
                              <=                                   0b      0b     15b
node09                        => ec2-13-209-84-50.ap-northeas      0b      0b     15b
                              <=                                   0b      0b     15b

──
TX:             cum:   11.2KB   peak:   19.1Kb         rates:    672b   1.11Kb  2.02Kb
RX:                    23.8KB           67.5Kb                   672b   1.00Kb  4.46Kb
TOTAL:                 35.0KB           86.6Kb                  1.31Kb  2.11Kb  6.48Kb 
{% endhighlight %}
<figure>
<figcaption class="caption">[Shell 1] iftop -i eth0</figcaption>
</figure>

[Interface]의 Network Bandwidth 사용량을 Src IP/Dst IP로 분류한 다음, 샤용량이 높은 순서에 따라서 출력한다. [Shell 1]은 "iftop -i eth0"을 이용하여 eth0의 Network Bandwidth 사용량을 출력하는 Shell의 모습을 나타내고 있다. 각 열은 순서대로 Packet의 Src/Dest, Packet의 방향, Packet의 Src/Dest, 2초동안 이동한 Packet량, 10초동안 이동한 Packet량, 40초 동안 이동한 Packet량을 나타낸다.
