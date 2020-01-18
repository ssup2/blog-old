---
title: OpenStack Keystone
category: Theory, Analysis
date: 2020-01-20T12:00:00Z
lastmod: 2020-01-20T12:00:00Z
comment: true
adsense: true
---

OpenStack의 Keystone을 분석한다.

### 1. OpenStack Keystone

![[그림 1] Keystone Components]({{site.baseurl}}/images/theory_analysis/OpenStack_Keystone/Keystone_Component.PNG){: width="700px"}

Keystone은 OpenStack에서 RBAC 기반의 인증(Authentication), 인가(Authorization)를 제공하고 OpenStack의 Service Discovey 기능도 제공한다. [그림 1]은 Keystone의 Backend와 각 Backend에 저장된 Keystone의 구성요소를 나타내고 있다. 각 구성 요소는 다음과 같다.

* User :
* Group : 
* Project : 
* Role : 
* Credentials : 
* Authentication : 
* Token : 
* Service : 
* Endpoint : 

#### 1.1. Authentication, Authorization

![[그림 2] Keystone Authentication, Authorization Flow]({{site.baseurl}}/images/theory_analysis/OpenStack_Keystone/Keystone_Auth_Flow.PNG){: width="700px"}

### 2. 참조

* [https://github.com/openstack/keystone](https://github.com/openstack/keystone)
* [https://blog.flux7.com/blogs/openstack/tutorial-what-is-keystone-and-how-to-install-keystone-in-openstack](https://blog.flux7.com/blogs/openstack/tutorial-what-is-keystone-and-how-to-install-keystone-in-openstack)
* [https://www.slideshare.net/eprasad/keystone-openstack-identity-service](https://www.slideshare.net/eprasad/keystone-openstack-identity-service)

