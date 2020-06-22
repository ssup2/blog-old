---
title: Directory Service, LDAP (Lightweight Directory Access Protocol)
category: Theory, Analysis
date: 2020-06-24T12:00:00Z
lastmod: 2020-06-24T12:00:00Z
comment: true
adsense: true
---

Directory Service와 Directory Service에서 이용되는 LDAP (Lightweight Directory Access Protocol)을 분석한다.

### 1. Directory Service

첫 Directory Service는 기업이 갖고 있는 물리적 Network Resource를 관리하기 위해서 Network Resource의 위치, 사양, 관리자 등의 정보를 보관하던 Data 저장소였다. **하지만 기업의 요구에 따라서 Network Resource 뿐만 아니라 기업이 관리해야하는 장비, 조직, 직원 등 다양한 물리적 Resource들을 관리하는 Data 저장소로 기능이 확장되었다.** 직원의 인증 정보도 Service Directory에 저장하여 관리할 수 있기 때문에, Directory Service를 통해서 사내의 인증 서비스도 구축할 수 있다.

Directory Service는 거의 번화가 발생하지 않는 물리적 Resource를 관리하는 용도로 많이 이용되기 때문에 일반적으로 Data 쓰기 보다는 Data 읽기에 중점을 두어 설계되어 있다. 또한 물리적 Resource의 다양한 특징을 저장하기 위해서 일반적으로 다양한 속성 (Attribute)를 저장할 수 있도록 설계되어 있다. Directory Service의 대표적인 구현체는 LDAP (Lightweight Directory Access Protocol)이 있다.

### 2. LDAP (Lightweight Directory Access Protocol)

![[그림 1] LDAP Schema]({{site.baseurl}}/images/theory_analysis/Docker_Component/Docker_Component.PNG)

LDAP은 의미 그대로 경량화된 Directory Service를 위한 Protocol이다. LDAP Server는 Tree 형태로 Data를 관리한다. [그림 1]은 Tree 형태를 갖고 있는 LDAP의 Schema를 나타내고 있다. Tree의 각 Node에는 하나의 속성이 저장되어 있는것을 확인할 수 있다. 이용할 수 있는 속성은 [링크](https://docs.bmc.com/docs/fpsc121/ldap-attributes-and-associated-fields-495323340.html)에서 확인할 수 있다. 많이 이용되는 속성은 다음과 같다.

* uid : User ID
* cn : Common Name
* l : Location
* ou : Organisational Unit
* o : Organisation
* dc : Domain Component
* st : State
* c : Country

### 3. 참조

* [https://docs.microsoft.com/en-us/previous-versions/windows/desktop/ldap/what-is-a-directory-service](https://docs.microsoft.com/en-us/previous-versions/windows/desktop/ldap/what-is-a-directory-service)
* [http://quark.humbug.org.au/publications/ldap/ldap_tut.html](http://quark.humbug.org.au/publications/ldap/ldap_tut.html)
* [https://blog.hkwon.me/use-openldap-part1/](https://blog.hkwon.me/use-openldap-part1/)
* [https://wiki.gentoo.org/wiki/Centralized_authentication_using_OpenLDAP](https://wiki.gentoo.org/wiki/Centralized_authentication_using_OpenLDAP)
* [https://www.linuxjournal.com/article/5505](https://www.linuxjournal.com/article/5505)
* [https://medium.com/happyprogrammer-in-jeju/ldap-%ED%94%84%ED%86%A0%ED%86%A0%EC%BD%9C-%EB%A7%9B%EB%B3%B4%EA%B8%B0-15b53c6a6f26](https://medium.com/happyprogrammer-in-jeju/ldap-%ED%94%84%ED%86%A0%ED%86%A0%EC%BD%9C-%EB%A7%9B%EB%B3%B4%EA%B8%B0-15b53c6a6f26)
* [http://umich.edu/~dirsvcs/ldap/doc/guides/slapd/1.html](http://umich.edu/~dirsvcs/ldap/doc/guides/slapd/1.html)
* [https://docs.bmc.com/docs/fpsc121/ldap-attributes-and-associated-fields-495323340.html]