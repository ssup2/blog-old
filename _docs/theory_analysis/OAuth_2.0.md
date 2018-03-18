---
title: OAuth 2.0
category: Theory, Analysis
date: 2017-03-05T12:00:00Z
lastmod: 2017-03-05T12:00:00Z
comment: true
adsense: true
---

인가(Authorization) 수행 시 이용되는 OAuth 2.0를 분석한다.

### 1. OAuth

![]({{site.baseurl}}/images/theory_analysis/OAuth_2.0/Legacy_Auth.PNG){: width="600px"}

OAuth은 현재 대부분의 인가 서비스에서 이용하고 있는 인가 Protocol이다. 위의 그림은 Legacy App에서의 인가 방법을 나타내고 있다. Legacy App은 User에게 ID, Password를 받아 Server에게 ID, Password를 전송하여 원하는 Resource를 받는다. 이렇게 ID, Password를 이용하여 인가를 수행하는 방식에는 몇가지 문제점이 있다.

먼저 App이 User의 ID, Password를 이용하여 악의적 동작을 수행하더라도 User나 Server에서 App의 악의적 동작을 감지하기 어렵다. Server에서는 ID, Password를 가지고 Resource 요청이 오기 때문에 어떤 요청이 악의적 동작을 위한 요청인지 판별하기 어렵다. 또한 ID, Password만 있으면 User의 모든 Resource를 자유롭게 접근할 수 있기 때문에 App의 Resource 요청을 제한하는 방법도 존재하지 않는다.

OAuth를 이용하는 App은 ID, Password를 이용하지 않고 Server가 발행한 **Access Token**을 이용한다. Access Token에는 **Scope(인가 범위), Timeout(인가 허용 시간)** 등의 인가 정보가 포함되어 있다. 따라서 App은 Access Token을 갖고 있더라도 제한된 시간안에 제한된 Resource만 접근 할 수 있다.

#### 1.1. Component

![]({{site.baseurl}}/images/theory_analysis/OAuth_2.0/OAuth_2.0_Component.PNG){: width="600px"}

위의 그림은 Web 환경에서 OAuth 2.0를 이용하여 인가 기능을 구성했을때 구성 요소를 세분화하여 나타낸 그림이다. User는 App을 이용하는 이용자를 나타낸다. OAuth 2.0에서는 Resource Owner라고 표현한다. User Agent는 User의 입력을 받아 App이나 Auth Server에게 전달하거나, App이나 Auth Server에게 받은 내용을 User에게 보여주는 역활을 수행한다.

App은 Web 환경이기 때문에 Web Server나, WAS에서 동작하는 App이라고 생각 할 수 있다. Auth Server는 Access Token을 발급하고 관리하는 Server이다. Resource Server는 User의 Resource를 App에게 제공한다.

#### 1.2. Access Token 발급

![]({{site.baseurl}}/images/theory_analysis/OAuth_2.0/OAuth_2.0_Access_Token_Flow.PNG)

* 1,2,3 - App 구동 중 특정 Resource 이용을 위해 User의 인가가 필요한 경우, App은 User Agent에게 Auth Server의 인가 URL로 Redirect 명령을 전달한다. Redirect 명령과 함께 App에서 필요한 Scope 정보 및 인가 완료 후 App으로 돌아오기 위한 App URL도 같이 보낸다.
* 4,5,6 - User Agent는 인가 URL로 이동하면서 인가 Scope 정보 및 App URL도 같이 전달한다. Auth Server는 Scope 정보를 확인하고 User 인증 및 Resource 인가를 위한 적절한 UI를 User Agent에게 전달한다.
* 7 - User는 UI를 통해서 User 인증 및 Resource 인가 작업을 진행한다. User 인증은 User의 ID, Password를 입력하여 진행하고, Resource 인가 작업은 App에서 요청한 Scope 정보를 보여주는 방식으로 진행된다.
* 8, 9 - User Agent는 인증, 인가 정보를 Auth Sever에게 전달하여 Auth Code와 App으로 돌아갈 App URL을 전달 받는다.
* 10,11,12 - User Agent는 App URL로 이동하면서 Auth Code도 같이 전달한다. App은 Auth Code를 통해 Resource에 접근 할 수 있는 Access Token과 Access Token을 새로 받을때 이용하는 Refresh Token을 받을 수 있다.

![]({{site.baseurl}}/images/theory_analysis/OAuth_2.0/Auth_Google_UI.PNG){: width="600px"}

위의 그림은 Google의 Authorization UI를 이용하여 User 인증 및 Resource 인가를 수행하는 과정을 나타내고 있다. Login을 수행하고 App이 요청한 인가 Scope 정보를 User에게 물어봐 동의를 구한다.

#### 1.3. Resource 접근

![]({{site.baseurl}}/images/theory_analysis/OAuth_2.0/OAuth_2.0_Resource_Access_Flow.PNG)

* 1,2 - User는 User Agent를 통해서 Resource를 요청한다.
* 3,4 - App은 발급받은 Access Token을 이용하여 Resource 요청과 함께 Access Token도 같이 전달한다.
* 5,6 - Resource Server는 Access Token이 유효한지 확인한 후 App에게 Resource를 전달한다.
* 7,8 - App은 User Agent를 통해서 User에게 Resource를 전달한다.

#### 1.4. Refresh Token 이용

Resource Token은 App이 이용하던 Access Token이 Timeout되어 Invaild 상태가 되었을경우 **새로운 Access Token**을 발급받기 위해 이용되는 Token이다. Auth Server는 App에게 Access Token을 **처음** 발급 할 때만 Refresh Token을 같이 전달한다. 따라서 App은 Refresh Token을 저장하고 이용해야 한다.

Auth Server는 Access Token을 반드시 전송할 필요 없다. Refresh Token이 없는 App은 Access Token이 Invaild한 상태가 되면 User에게 요청하여 다시 Access Token을 발급 받아야 한다. Refresh Token은 **Bearer Token**이라고도 불린다. 아래의 그림은 App이 Refresh Token을 이용하는 과정을 나타낸다.

![]({{site.baseurl}}/images/theory_analysis/OAuth_2.0/OAuth_2.0_Refresh_Token_Flow.PNG)

* 1,2,3 - App은 User의 요청을 받아 Access Token을 이용하여 Resource Server에게 Resource를 요청한다.
* 4,5 - Resource Server는 Auth Server에게 Access Token이 유요한지 물어본다.
* 6,7,8 - App이 Access Token이 Invaild 하다는 결과를 받으면 Auth Server에게 Refresh Token을 이용하여 새로운 Access Token을 받는다.
* 9 ~ 14 - App은 새로 받은 Access Token을 이용하여 다시 Resource를 요청하고, 받은 Resource를 User Agent를 통해서 Agent에게 전달한다.

### 2. 참조

* [http://jlabusch.github.io/oauth2-server/index.html](http://jlabusch.github.io/oauth2-server/index.html)
* [https://opentutorials.org/course/2473/16571](https://opentutorials.org/course/2473/16571)
* [https://db-blog.web.cern.ch/blog/luis-rodriguez-fernandez/2017-04-oracle-jet-ords-oauth2](https://db-blog.web.cern.ch/blog/luis-rodriguez-fernandez/2017-04-oracle-jet-ords-oauth2)
