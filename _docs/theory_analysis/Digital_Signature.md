---
title: Digital Signature
category: Theory, Analysis
date: 2018-10-22T12:00:00Z
lastmod: 2018-10-22T12:00:00Z
comment: true
adsense: true
---

Digital Signature 기법을 분석한다.

### 1. Digital Signature

![]({{site.baseurl}}/images/theory_analysis/Digital_Signature/Digital_Signature.PNG)

Digital Signature 기법은 의미 그대로 Digital Data에 서명을 통해 서명자가 해당 Digital Data를 보증하는 기법이다. Digital Signature 기법은 Signing 단계와 Verification 2단계로 나눌 수 있다. Signing은 의미 그대로 서명하는 단계이며, Digital Data를 Hashing하여 Binary로 변환한뒤 서명자의 Private Key를 통해 암호화하여 Digital Signature를 얻는다. 그 후 Digital Signature는 원본 Digital Data와 같이 Digital Data 수신자에게 전달 된다.

Verification은 의미 그대로 Digital Data가 서명자로부터 인증된 Data인지 확인하는 단계이다. Digital Data 수신자는 받은 Data를 Hashing하여 Binary로 변환한다. 또한 Digital Signature를 서명자의 Public Key를 이용하여 Digital Data의 Binary로 복호화 한다. 두 Binary를 비교하여 동일하다면 Digital Data 수신자는 해당 Data가 서명자로부터 보증받은 Digital Data라는걸 알 수 있다. Digital Data가 변경되었거나 서명자가 아닌 다른 사람의 Public Key를 이용하여 복호화 하는경우 두 Binary가 다른 값을 갖게되기 때문이다.

### 2. 참조

* [https://blog.mailfence.com/how-do-digital-signatures-work/](https://blog.mailfence.com/how-do-digital-signatures-work/)
