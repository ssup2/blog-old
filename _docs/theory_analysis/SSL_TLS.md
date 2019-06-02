---
title: SSL (Secure Socket Layer), TLS (Transport Layer Security)
category: Theory, Analysis
date: 2018-10-15T12:00:00Z
lastmod: 2018-10-15T12:00:00Z
comment: true
adsense: true
---

SSL (Secure Socket Layer), TLS (Transport Layer Security)를 분석한다.

### 1. SSL (Secure Socket Layer), TLS (Transport Layer Security)

SSL (Secure Socket Layer), TLS (Transport Layer Security)는 TCP위에서 동작하는 표준 보안 Protocol이다. HTTPS가 SSL,TLS 위에서 동작하는 대표적인 Protocol이다. SSL/TLS는 비대칭키에 이용되는 알고리즘인 **RSA**의 Overhead를 줄이기 위해 대칭키와 비대칭키 둘다 이용한다. Client는 Data 암호화에 이용할 대칭키를 Server의 비대칭 Public Key로 암호화 한뒤 Server에게 전달한다. 그 후 Server는 비대칭 Private Key로 대칭키를 얻어낸뒤 Client와 통신한다. 대칭키를 암호화/복호화 할 때만 비대칭키를 이용하고 Data는 대칭키를 이용하는 방식으로 비대칭키 연산 Overhead를 줄인다.

#### 1.1. Handshake

![[그림 1] SSL/TLS Handshake 과정]({{site.baseurl}}/images/theory_analysis/SSL,TLS/SSL,TLS_Handshake_No_Session_ID.PNG){: width="600px"}

[그림 1]은 SSL/TLS의 첫 Handshake 과정을 나타낸다.

* 1 : Client는 Server에게 Client Hello Message를 전달한다. 이 Client Hello Message에는 Client가 지원하는 SSL/TLS Version, Client가 생성하는 Random 값, Client에서 지원가능한 Cipher Suite List 등을 포함하고 있다. Cipher Suite는 SSL/TLS 통신에 이용하는 Protocol, Key 교환방식, 암호화 방식 등의 정보를 포함한다.
* 2 : Server는 Client Hello에 대한 응답으로 Server와 Client에서 지원가능한 가장 높은 SSL/TLS Version, Server에서 생성하는 Random 값, Server에서 발급하는 **Session ID**, Client의 Cipher Suite List 중에서 Server가 선택한 Cipher Suite를 전달한다.
* 3,6 : Server는 Client에게 Server Certificate를 전달하고 Server hello done Message를 전달한다.
* 8 : Client는 Server Certificate의 서명이 유효한지 확인한다. 서명이 유효하다면 Client는 Protocol Version과 Random 값으로 구성된 **Pre-master Secret**를 Server Certificate에 포함된 Server Public Key를 이용하여 암호화 한뒤 Server에게 전달한다. Server와 Client는 각각 Client가 생성한 Random 값, Server가 생성한 Random 값, Pre-master Secret을 이용하여 **Master Secret**를 얻는다.
* 10, 11 : Client는 Handshake 종료를 위해서 Change Cipher Spec을 1로 전송하고 Finish를 전송한다.
* 12, 13 : Server는 Handshake 종료를 위해서 Change Cipher Spec을 1로 전송하고 Finish를 전송한다.
* 14 : Server와 Client는 Master Secret을 기반으로 **Session Key**을 만들고 Session Key를 대칭키로 이용하여 Packet을 암호화 한다.

아래는 Optional 과정에 대한 설명이다.

* 4 : 만약 Server Certificate에 Server Public Key가 포함되어 있지 않으면 Server는 Server Public Key를 대체할 임시키를 전송한다.
* 5,7,9 : Server는 Handshake 수행 중 Client Certificate를 요청 할 수 있다. Certificate를 요청받은 Client는 Server에게 Client Certificate를 전송한다. 또한 지금까지의 Handshake Message들의 Hash 값을 Client Private Key로 서명한뒤 그 결과를 Client Certificate Verify Message에 포함하여 Server에게 전송한다. Server는 Client Certificate로부터 얻을 수 있는 Client Public Key, Client로부터 받은 Handshake Message들의 서명, Handshake Message들을 통해서 올바른 Client인지 확인 할 수 있다.

#### 1.2. Resumed Session

![[그림 2] SSL/TLS Session 재구성]({{site.baseurl}}/images/theory_analysis/SSL,TLS/SSL,TLS_Handshake_Session_ID.PNG){: width="600px"}

[그림 2]는 Client가 이전에 Handshake가 완료된 Session에 연결하면서 수행하는 간소화된 Handshake 과정을 나타내고 있다. Client는 이전 Session ID와 이전 Session에서 이용하는 Master Secret을 저장하고 있어야 한다. Server 또한 이전 Session ID와 이전 Session에서 이용하는 Master Secret을 저장하고 있어야 한다.

* 1 : Client는 Server에게 Client Hello Message를 전달한다. Client는 첫 Handshake 과정에서 보냈던 Client가 지원하는 SSL/TLS Version, Client가 생성하는 Random 값, Client에서 지원가능한 Cipher Suite List 등과 함께 이전의 Handshake 과정에서 받은 Session ID를 그대로 Server에게 전달한다.
* 2 : Server는 Session ID를 확인한다. Session ID가 유효하다면 Client에게 동일 Session ID를 전송하여 Client에게 Session이 유효한 것을 알린다. Session ID가 유효하지 않다면 다른 Session ID를 보내고 첫 Handshake와 동일한 과정으로 Handshake가 진행된다.
* 3,4,5,6 : Client와 Server에서 Change Cipher Spec 및 Finish를 전송하여 Handshake를 마친다.
* 14 : Server와 Client는 Master Secret을 기반으로 **Session Key**을 만들고 Session Key를 대칭키로 이용하여 Packet을 암호화 한다.

#### 1.3. CA (Certificate Authority), Certificate

![[그림 3] Certificate Tree]({{site.baseurl}}/images/theory_analysis/SSL,TLS/Certificate_Tree.PNG){: width="700px"}

CA(Certificate Authority)는 Certificate를 발행하고 인증하는 기관이다. CA중에서 최상위 Certificate를 발급하는 CA는 **Root CA**라고 하며 Root CA에 발급하는 Certificate를 **Root Certificate**라고 한다. Root Certificate는 자기 자신이 서명하기 때문에 **Self-signed Certificate**이기도 하다. Root Certificate는 웹브라우저에 기본적으로 설치된다.

Root CA의 Private Key를 이용하여 하위 CA가 발행한 Certificate에 서명을 하면, Root Certificate의 신뢰 때문에 하위 CA의 Certificate에게도 신뢰가 부여된다. 또한 신뢰도를 얻은 하위 CA의 Private Key를 이용하여 또다른 하위 CA가 발행한 Certificate에게 신뢰를 부여 할 수 있다. 이처럼 Certificate의 관계는 Root Certificate가 Root가 되어 **Tree 구조**의 관계를 갖는다. 따라서 Tree의 Leaf에 가까운 Certificate일수록 다수의 상위 Certificate가 필요하게 된다.

### 2. 참조
* [https://en.wikipedia.org/wiki/Transport_Layer_Security](https://en.wikipedia.org/wiki/Transport_Layer_Security)
* [https://sites.google.com/site/amitsciscozone/home/security/ssl-connection-setup](https://sites.google.com/site/amitsciscozone/home/security/ssl-connection-setup)
* [https://www.ibm.com/support/knowledgecenter/en/SSFKSJ_7.1.0/com.ibm.mq.doc/sy10660\_.htm](https://www.ibm.com/support/knowledgecenter/en/SSFKSJ_7.1.0/com.ibm.mq.doc/sy10660\_.htm)
* [https://wiki.kldp.org/HOWTO/html/SSL-Certificates-HOWTO/x70.html](https://wiki.kldp.org/HOWTO/html/SSL-Certificates-HOWTO/x70.html)
* [http://whitelka.tistory.com/103](http://whitelka.tistory.com/103)
* [https://rsec.kr/?p=455](https://rsec.kr/?p=455)
