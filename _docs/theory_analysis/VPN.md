---
title: VPN (Virtual Private Network)
category: Theory, Analysis
date: 2019-11-01T12:00:00Z
lastmod: 2019-11-01T12:00:00Z
comment: true
adsense: true
---

VPN (Virtual Private Network)을 분석한다.

### 1. VPN (Virtual Private Network)

![[그림 1] VPN Architecture]({{site.baseurl}}/images/theory_analysis/VPN/VPN_Achitecture.PNG){: width="700px"}

VPN은 Public Network를 이용하여 Private Network를 구축하는 기술이다. [그림 1]은 VPN Architecture를 나타내고 있다. VPN은 Public Network에 VPN Tunnel을 구축하여 Private Network를 구축한다. VPN Tunnel은 VPN Gateway에 의해서 구축되며, PPTP (Point-to-Point Tunneling Protocol), L2TP (Layer Two Tunneling Protocol)등의 Tunneling 기법과 IPSec (Internet Protocol Security), SSL (Secure Socket Layer)등의 암호화 기법을 이용한다. VPN Gateway는 물리 장비이거나, 가상의 Software 장비가 될 수 있다.

### 2. 참조

* [https://www.slideshare.net/Kajal_Thakkar/vpn-14074779](https://www.slideshare.net/Kajal_Thakkar/vpn-14074779)
* [https://namu.wiki/w/%EA%B0%80%EC%83%81%20%EC%82%AC%EC%84%A4%EB%A7%9D](https://namu.wiki/w/%EA%B0%80%EC%83%81%20%EC%82%AC%EC%84%A4%EB%A7%9D)