---
title: UUID (Universally Unique IDentifier)
category: Theory, Analysis
date: 2021-07-10T12:00:00Z
lastmod: 2021-07-10T12:00:00Z
comment: true
adsense: true
---

### 1. UUID (Universally Unique IDentifier)

![[그림 1] UUID Format]({{site.baseurl}}/images/theory_analysis/UUID/UUID_Format.PNG){: width="400px"}

UUID는 의미 그대로 어느곳에서도 고유한 ID를 의미한다. [그림 1]은 UUID의 Format을 나타내고 있다. 8,4,4,4,12 총 **32개의 문자**를 포함하고 있으며 각 문자는 16진수로 구성되며, Dash까지 포함한다면 36개의 문자로 구성된다. UUID를 Bit로 나타내면 **"32*4=128" 개수의 Bit**로 구성된다.

수많은 문자로 구성되어 있는 만큼 임의의 값으로 각 Server에서 UUID를 생성하더라도 생성된 UUID끼리 서로 충돌이 발생할 확률이 매우 낮다. 따라서 App이 UUID를 이용할 경우 APP은 UUID의 중복 검사를 진행하지 않고 이용하는 경우가 많다.

UUID는 UUID의 생성 방법에 따라서 **Version**이 존재하며 UUID에 Version 정보가 저장되어 있는 4 Bit의 Version Field가 존재한다. Version은 현재 1~5까지 존재하며 [그림 1]의 경우에는 Version 4를 나타내고 있다. UUID에는 UUID의 Foramt 정보를 포함하고 있는 **Variant**가 존재하며 UUID에 3 Bit의 Varient Field가 존재한다.

#### 1.1. Version

UUID는 생성 방법에 따라서 Version이 존재한다. TimeStamp 기반의 v1/v2, 완전 Random 기반의 v4, Hashing 기반의 v3/v5가 존재한다. 다만 실제로 v1/v4/v5가 주로 이용된다. Random한 UUID를 생성하기 위해서는 v1/v4를 이용하면되고 고정된 UUID를 생성하기 위해서는 v5를 이용하면 된다.

##### 1.1. v1

![[그림 1] UUID v1]({{site.baseurl}}/images/theory_analysis/UUID/UUID_V1.PNG){: width="400px"}

v1 UUID는 Timestamp를 기반으로 UUID를 생성한다. [그림 1]은 v1 UUID의 생성 과정을 나타내고 있다. 앞 부분에는 Timestamp가 쪼개져 UUID에 포함되는 것을 확인할 수 있다. Timestamp는 1582년 10월 15일 자정을 기준으로 100ns마다 1씩 증가하는 값이다. 뒷 부분에는 UUID를 생성하는 Computer의 MAC Address가 저장된다.

이러한 v1 UUID 생성 방법으로 인해서 동일한 Computer에서 동작하는 App이 100ns 동안에 UUID를 여러개 생성하는 경우, 모든 UUID가 동일하게 된다. 따라서 짧은 시간동안 많은 UUID가 생성되는 App은 v1 UUID 사용을 피해야 한다. v1 UUID 뒷 부분에는 Mac Address가 저장되기 때문에 v1 UUID를 통해서 해당 v1 UUID가 어느 Computer에서 생성되었는지 추적할 수 있다.

##### 1.2. v4

v4 UUID는 완전 Random을 기반으로 UUID를 생성한다. UUID의 Version, Variant Field를 제외한 나머지 Field는 완전하게 Random으로 생성되어 v4 UUID가 구성된다.

##### 1.3. v5

v5 UUID는 **SHA-1** Hashing을 기반으로 UUID를 생성한다. v5 UUID를 생성하기 위해서는 **Namespace**와 **Name**값이 필요하다. Namespace와 Name값이 동일하다면 동일한 UUID가 생성된다. Namespace 값은 아래와 같이 정의되어 있으며, 정의된 값 말고 다른 값도 이용할 수 있다.

* NAMESPACE_DNS : Name이 Domain 이름이다.
* NAMESPACE_URL : Name이 URL이다.
* NAMESPACE_OID : Name이 OID (Object Identitfier)이다.
* NAMESPACE_X500 : Name이 LDAP Protocol의 Directory Name이다.

##### 1.4. v2

v2 UUID는 v1 UUID와 동일하게 Timestamp 기반이지만 Timestamp Filed가 줄어들고 Domain/Identifier Field가 추가되었다. v2 UUID의 Timestamp 값은 약 7분 정도 지나야 1씩 증가한다. v2 UUID는 일반적인 UUID가 아닌 DCE (Distributed Computing Environment) 환경을 위한 UUID이기 때문에 잘 이용되지 않는다.

##### 1.5. v3

v5 UUID는 v3 UUID와 동일하지만 MD5 Hahsing Algorithm을 이용하여 Hashing을 수행한다는 점이 다르다. MD5 Hashing Algorithm은 현재 보안적 취약점을 이용해서 Reverse Hashing이 쉽게 가능한 상태이다. 따라서 현재 v3 UUID 보다는 v5 UUID를 이용하는 것을 권장하고 있다.

### 2. with DB

### 3. 참조

* [https://en.wikipedia.org/wiki/Universally_unique_identifier](https://en.wikipedia.org/wiki/Universally_unique_identifier)
* [https://uuid.ramsey.dev/en/latest/introduction.html](https://uuid.ramsey.dev/en/latest/introduction.html)
* [https://docs.python.org/3/library/uuid.html](https://docs.python.org/3/library/uuid.html)
* [https://www.uuidtools.com/what-is-uuid](https://www.uuidtools.com/what-is-uuid)
* [https://www.sohamkamani.com/uuid-versions-explained/](https://www.sohamkamani.com/uuid-versions-explained/)
* [https://www.davidangulo.xyz/advantages-and-disadvantages-of-uuid/](https://www.davidangulo.xyz/advantages-and-disadvantages-of-uuid/)
