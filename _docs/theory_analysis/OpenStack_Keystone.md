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

![[그림 1] Keystone Components]({{site.baseurl}}/images/theory_analysis/OpenStack_Keystone/Keystone_Component.PNG)

Keystone은 OpenStack에서 RBAC 기반의 인증(Authentication), 인가(Authorization)를 제공하고 OpenStack의 Service Discovey 기능도 제공한다. [그림 1]은 Keystone의 Backend들과 각 Backend에 저장된 Keystone의 구성요소들을 나타내고 있다. 각 구성 요소는 다음과 같다.

* Identity Backend : User와 Group 정보를 저장한다. SQL DB나 LDAP을 이용하여 구성한다. User는 OpenStack Service를 이용하는 한명의 사람, 하나의 System 또는 하나의 Service를 의미한다. Group은 다수의 User의 집합을 의미한다. Group을 이용하여 다수의 User를 쉽게 제어할 수 있다.

* Assignment Backend : Project, Domain, Role 및 Role Assignment 정보를 저장한다. SQL DB를 이용하여 구성한다. Project는 Server, Image 같은 Resource의 Isolation 및 Grouping을 위한 단위를 의미한다. 과거에 OpenStack에서는 Tenant라는 이름으로 지칭되었다. Domain은 User와 Project의 Isolation 및 Grouping을 위한 단위를 의미한다. User 이름과 Project 이름이 동일하더라도 각각 다른 Domain에 소속되어 있다면 하나의 OpenStack에서 이용할 수 있다. Role은 권한의 집합을 의미하고, Role Assignment는 Role의 할당 정보를 의미한다. User 또는 Group은 각 Project 마다 다른 Role을 갖을 수 있다.

* Policy Backend : Policy 정보를 저장한다. Oslo RBAC Engine을 이용하여 구성한다. Policy는 Rule이라고 불리는 명시된 권한의 집합을 의미한다. Role은 Rule의 집합으로 정의된다.

* Credentials Backend : Credentials 정보를 저장한다. SQL DB를 이용하여 구성한다. Credentials는 OpenStack Service를 이용하는 OpenStack Client(Application)의 인증, 인가를 위해서 이용된다. Keystone을 이용하여 언제든지 Credentials 생성/삭제가 가능하다.

* Token Backend : Token 정보를 저장한다. SQL DB나 Memcached를 이용하여 구성한다. Token은 인증이 완료된 OpenStack Client가 갖고 있는 임의의 값이다. OpenStack Client는 OpenStack Service에게 요청시 Token값도 같이 전달하여 자신이 인증 받은 OpenStack Client인지 증명한다. Token Type에 따라서 Token에는 인가 정보도 같이 들어갈 수 있다.

* Endpoint Backend : Service Endpoint 정보를 저장하고 있다. SQL DB를 이용하여 구성한다. Service Endpoint는 OpenStack Client가 OpenStack Service에 접근하기 위한 URL을 의미한다.

#### 1.1. Components Relation

![[그림 1] Keystone Components Relation]({{site.baseurl}}/images/theory_analysis/OpenStack_Keystone/Keystone_Component_Relation.PNG){: width="550px"}

[그림 1]은 Keystone의 주요 구성요소들의 관계를 나타내고 있다. Policy는 Domain 밖의 전역 공간에 위치한다. Policy안의 Rule의 집합으로 Role이 정의된다. Role은 특정 Domain안에 소속되거나 Domain 밖의 전역 공간에 위치한다. User, Group, Project는 특정 Domain안에 소속된다. Group은 User의 집합으로 구성된다. User 또는 Group은 각 Project마다 다른 Role을 갖도록 Mapping 될 수 있다.

#### 1.2. Authentication, Authorization Flow

![[그림 3] Keystone Authentication, Authorization Flow with Server Side Authorization]({{site.baseurl}}/images/theory_analysis/OpenStack_Keystone/Keystone_Auth_Flow_Server_Side_Authorization.PNG)

![[그림 4] Keystone Authentication, Authorization Flow with Client Side Authorization]({{site.baseurl}}/images/theory_analysis/OpenStack_Keystone/Keystone_Auth_Flow_Client_Side_Authorization.PNG)

### 2. 참조

* [https://github.com/openstack/keystone](https://github.com/openstack/keystone)
* [https://www.oreilly.com/library/view/identity-authentication-and/9781491941249/ch01.html](https://www.oreilly.com/library/view/identity-authentication-and/9781491941249/ch01.html)
* [https://blog.flux7.com/blogs/openstack/tutorial-what-is-keystone-and-how-to-install-keystone-in-openstack](https://blog.flux7.com/blogs/openstack/tutorial-what-is-keystone-and-how-to-install-keystone-in-openstack)
* [https://www.slideshare.net/eprasad/keystone-openstack-identity-service](https://www.slideshare.net/eprasad/keystone-openstack-identity-service)

