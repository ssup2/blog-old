---
title: Overlay Network, VXLAN
category: Theory, Analysis
date: 2017-05-23T12:00:00Z
lastmod: 2017-05-23T12:00:00Z
comment: true
adsense: true
---

Cloud 환경에서 Network 가상화를 위해 이용하는 Overlay Network를 분석하고, Overlay Network의 구현을 가능하게 하는 VXLAN 기술을 분석한다.

### 1. Overlay Network

<img src="{{site.baseurl}}/images/theory_analysis/Overlay_Network_VXLAN/Overlay.PNG" width="500px">

### 2. VXLAN

<img src="{{site.baseurl}}/images/theory_analysis/Overlay_Network_VXLAN/VXLAN_Overview.PNG" width="500px">

#### 2.2. VXLAN Packet

![]({{site.baseurl}}/images/theory_analysis/Overlay_Network_VXLAN/VXLAN_Packet.PNG)

#### 2.3. VXLAN Address Learning

![]({{site.baseurl}}/images/theory_analysis/Overlay_Network_VXLAN/VXLAN_Address_Learning.PNG)

#### 2.4. VXLAN Unicast

![]({{site.baseurl}}/images/theory_analysis/Overlay_Network_VXLAN/VXLAN_Unicast.PNG)

### 3. 참조

* [http://youngmind.tistory.com/entry/Network-Overlay-VXLAN-%EB%B6%84%EC%84%9D-1](http://youngmind.tistory.com/entry/Network-Overlay-VXLAN-%EB%B6%84%EC%84%9D-1)

*  [https://www.slideshare.net/KwonSunBae/vxlan-deep-dive-session-rev05-final](https://www.slideshare.net/KwonSunBae/vxlan-deep-dive-session-rev05-final)
