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

#### 1.1. Authentication, Authorization Components Relations

![[그림 2] Keystone Authentication, Authorization Components Relations]({{site.baseurl}}/images/theory_analysis/OpenStack_Keystone/Keystone_Component_Relation.PNG){: width="550px"}

[그림 2]는 Keystone의 인증/인가 관련 주요 구성요소들의 관계를 나타내고 있다. Policy는 Domain 밖의 전역 공간에 위치한다. Policy안의 Rule의 집합으로 Role이 정의된다. Role은 특정 Domain안에 소속되거나 Domain 밖의 전역 공간에 위치한다. User, Group, Project는 특정 Domain안에 소속된다. Group은 User의 집합으로 구성된다. User 또는 Group은 각 Project마다 다른 Role을 갖도록 Mapping 될 수 있다.

#### 1.2. Service Authentication, Authorization with Keystone

![[그림 3] Service Authentication, Authorization with Keystone and Server Side Authorization]({{site.baseurl}}/images/theory_analysis/OpenStack_Keystone/Keystone_Auth_Flow_Server_Side_Authorization.PNG)

![[그림 4] Service Authentication, Authorization with Keystone and Client Side Authorization]({{site.baseurl}}/images/theory_analysis/OpenStack_Keystone/Keystone_Auth_Flow_Client_Side_Authorization.PNG)

[그림 3]과 [그림 4]는 OpenStack의 Service에서 Keystone을 이용하여 인증/인가를 수행하는 과정을 나타내고 있다. [그림 3], [그림 4] 둘다 OpenStack Client가 Keystone에게 User ID/Password 또는 Credential을 전달하여 Token을 얻는 과정을 동일하다. 그뒤의 과정은 Token Type에 따라서 달라진다. UUID 또는 Fernet Type의 Token에는 Token의 유효성 검사를 위한 정보 및 인증 인가를 위한 정보가 포함되어 있지 않다. 따라서 [그림 3]처럼 OpenStack Client 또는 다른 OpenStack Service로부터 Token을 받은 OpenStack Service는 KeyStone을 통해서 Token의 유효성 및 인가 정보를 확인해야 한다. 이러한 방식을 Server Side Authorization이라고 부른다.

PKI 또는 JWT Type의 Token에는 Token의 유효성 검사를 위한 정보 및 인가를 위한 정보가 포함되어 있다. 따라서 [그림 4]처럼 OpenStack Client 또는 다른 OpenStack Service로부터 Token을 받은 OpenStack Service는 Keystone의 도움 없이 Token의 유효성 및 인가 정보를 확인할 수 있다. 이러한 방식을 Client Side Authorization이라고 부른다.

### 2. 참조

* [https://github.com/openstack/keystone](https://github.com/openstack/keystone)
* [https://www.oreilly.com/library/view/identity-authentication-and/9781491941249/ch01.html](https://www.oreilly.com/library/view/identity-authentication-and/9781491941249/ch01.html)
* [https://blog.flux7.com/blogs/openstack/tutorial-what-is-keystone-and-how-to-install-keystone-in-openstack](https://blog.flux7.com/blogs/openstack/tutorial-what-is-keystone-and-how-to-install-keystone-in-openstack)
* [https://www.slideshare.net/eprasad/keystone-openstack-identity-service](https://www.slideshare.net/eprasad/keystone-openstack-identity-service)

