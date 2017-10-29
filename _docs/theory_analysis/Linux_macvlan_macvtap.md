---
title: Linux macvlan, macvtap
category: Theory
date: 2017-10-29T12:00:00Z
lastmod: 2017-10-29T12:00:00Z
comment: true
adsense: true
---

Linux의 Virtual Network Device인 macvlan과 macvtap에 대해서 분석한다.

### 1. macvlan

![]({{site.baseurl}}/images/theory_analysis/Linux_macvlan_macvtap/macvlan_Component.PNG){: width="500px"}

![]({{site.baseurl}}/images/theory_analysis/Linux_macvlan_macvtap/macvlan_Example.PNG){: width="600px"}

![]({{site.baseurl}}/images/theory_analysis/Linux_macvlan_macvtap/macvlan_Address_Manage.PNG){: width="700px"}

![]({{site.baseurl}}/images/theory_analysis/Linux_macvlan_macvtap/macvlan_Private_Mode.PNG){: width="500px"}

![]({{site.baseurl}}/images/theory_analysis/Linux_macvlan_macvtap/macvlan_Vepa_Mode.PNG){: width="500px"}

![]({{site.baseurl}}/images/theory_analysis/Linux_macvlan_macvtap/macvlan_Bridge_Mode.PNG){: width="500px"}

![]({{site.baseurl}}/images/theory_analysis/Linux_macvlan_macvtap/macvlan_Passthru_Mode.PNG){: width="500px"}

### 2. macvtap

* macvlan code - [https://github.com/torvalds/linux/blob/80cee03bf1d626db0278271b505d7f5febb37bba/drivers/net/macvlan.c](https://github.com/torvalds/linux/blob/80cee03bf1d626db0278271b505d7f5febb37bba/drivers/net/macvlan.c)
* macvtap code - [https://github.com/torvalds/linux/blob/80cee03bf1d626db0278271b505d7f5febb37bba/drivers/net/macvtap.c](https://github.com/torvalds/linux/blob/80cee03bf1d626db0278271b505d7f5febb37bba/drivers/net/macvtap.c)
* macvlan - [https://hicu.be/bridge-vs-macvlan](https://hicu.be/bridge-vs-macvlan)
