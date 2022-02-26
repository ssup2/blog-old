---
title: OAuth 2.0
category: Theory, Analysis
date: 2017-03-05T12:00:00Z
lastmod: 2017-03-05T12:00:00Z
comment: true
adsense: true
---

인가(Authorization) 수행 시 이용되는 OAuth 2.0를 분석한다.

### 1. OAuth 2.0

![[그림 1] ID/Password Auth]({{site.baseurl}}/images/theory_analysis/OAuth_2.0/ID_Password_Auth.PNG){: width="700px"}

OAuth 2.0은 현재 대부분의 인가 서비스에서 이용하고 있는 **인가(Authorization)** Protocol이다. 기존의 User의 ID/Password를 통한 예전의 인증/인가 방식의 문제점을 개선하기 위해서 나온 Protocol이다. [그림 1]은 예전에 App에서 접근하던 User의 ID/Password를 통한 인증/인가 방법을 나타내고 있다. App에서 Google, Facebook과 같은 Service Provider의 API를 접근해야 하는 경우, 예전에는 User가 App에게 입력한 ID/Password를 이용하여 Service Provider의 API Server에 요청을 전송하는 방식을 이용했다.

이와 같은 ID/Password 기반의 Auth 방식은 몇가지 문제점이 존재한다. 먼저 App이 User의 ID/Password를 이용하여 악의적 동작을 수행하더라도 User나 API Server에서는 App의 악의적 동작을 제한하거나 감지할 수 있는 방법이 존재하지 않는다. 또한 App도 입력받은 User의 ID/Password를 저장하고 있어야 하기 때문에 App의 보안에도 많은 신경을 써야한다.

OAuth 2.0을 이용하면 이와같은 문제점들을 해결할 수 있다. OAuth 2.0을 이용하면 App은 User의 ID/Password가 아닌 Authorization Server에게 받은 **Access Token**을 이용하여 API Server에게 접근한다. Access Token은 특정 시간이 지나면 만료되는 특성을 갖는다. 따라서 App은 Access Token을 갖고 있더라도 제한된 시간안에 제한된 Resource만 접근 할 수 있기 때문에 Access Token을 이용하여 App의 악의적 동작을 막을 수 있다. 또한 App은 User의 ID/Password를 저장할 필요가 없기 때문에 App의 보안에도 유리하다.

OAuth 2.0을 이용하는 App들은 대부분 직접 User의 정보를 관리하지 않고 OAuth 2.0을 통해서 Service Provider의 User API에 접근하여 Service Provider가 관리하고 있는 User 정보를 이용한다. 따라서 User가 Service Provider에 회원가입 과정을 통해서 User의 정보를 등록해 놓으면, 해당 User는 OAuth 2.0을 이용하는 다양한 App들을 회원가입 없이 이용할 수 있게 된다.

#### 1.1. Component

![[그림 2] OAuth 2.0 Component]({{site.baseurl}}/images/theory_analysis/OAuth_2.0/OAuth_2.0_Component.PNG){: width="700px"}

[그림 2]는 Web 환경에서 OAuth 2.0를 이용하여 인가 기능을 구성했을때 구성 요소를 세분화하여 나타낸 그림이다. **User**는 App을 이용하는 이용자를 나타낸다. OAuth 2.0에서는 **Resource Owner**라고 명칭한다. 여기서 **Resource**는 Data 정도로 이해하면 된다. **User Agent**는 User의 입력을 받아 App이나 Authorization Server에게 전달하거나, App이나 Authorization Server에게 전달 받은 내용을 User에게 보여주는 역할을 수행한다. 일반적으로 Web 환경에서 User Agent는 Web Brower를 의미한다.

**App**은 Authorization Server로부터 Resource 접근 권한을 받으려는 App을 나타낸다. Web 환경이기 때문에 App은 Web Server나, WAS라고 생각할 수 있다. **Authorization Server**는 Access Token을 발급하고 관리하는 Server이다. API Server는 User의 Resource(Data)를 제공하는 Server를 의미한다. OAuth 2.0에서는 **Resource Server**라고 명칭한다. 일반적으로 Authorization Server와 Resource Server는 동일한 Service Provider가 제공한다.

#### 1.2. Access Token

Access Token은 인가 권한을 갖고 있는 Token이다. App은 Access Token을 이용하여 특정 API Server에 접근할 수 있다. Access Token에는 **Timeout(인가 허용 시간), Scope(인가 범위)** 등의 인가 정보가 포함되어 있다. 따라서 Access Token은 Timeout 이후에는 만료되는 특징을 갖는다. 또한 Access Token을 통해서 모든 Resource가 아닌 인가 범위에 포함된 Resource에만 접근할 수 있다.

중요한 점은 Access Token은 인증 정보는 포함되어 있지 않고 오직 **인가** 정보만을 포함하고 있는 Token이다. 즉 Access Token을 이용하면 어떠한 App이던 Access Token의 권한을 이용할 수 있다는 의미다. 따라서 Access Token은 외부에 노출되면 안되며, Access Token은 인증된 App만 얻을 수 있도록 설계되어야 한다. App에서 인증 정보가 필요한 경우에는 OAuth 2.0에 기반하고 있는 OIDC (OpenID Connect)를 이용할 수 있다.

App이 Authorization Server로부터 Access Token을 발급 받기 위해서는 App을 Authorization Server에 반드시 등록해야 한다. App을 Authorization Server에 등록되면 Authorization Server는 **Client ID**와 **Client Secret**을 발급한다. Client ID는 Authorization Server에서 App 구분을 위한 값이고, Client Secret은 Access Token 발급을 위한 값이다. Client Secret은 외부로 노출되면 안된다.

![[그림 3] OAuth 2.0 Access Token 발급 과정]({{site.baseurl}}/images/theory_analysis/OAuth_2.0/OAuth_2.0_Access_Token_Flow.PNG)

[그림 3]은 Access Token의 발급 과정을 나타내고 있다.

* 1,2,3 : App 구동 중 특정 Resource 이용을 위해 User의 인가가 필요한 경우, App은 User Agent에게 Auth Server의 인가 URL로 Redirect 명령을 전달한다. Redirect 명령과 함께 Client ID, App에서 필요한 Scope 정보, 인가 완료 후 App으로 돌아오기 위한 App의 Return URL도 같이 보낸다. Client ID, Scope, Return URL 모두 인가 URL의 URL Query 형태로 전달된다.
* 4,5,6 : Auth Server는 URL Query로 전달된 Client ID, Scope, Return URL 정보를 바탕으로 User 인증 및 Resource 인가를 위한 적절한 UI를 User Agent에게 전달한다.
* 7 : User는 UI를 통해서 User 인증 및 Resource 인가 작업을 진행한다. User 인증은 User의 ID/Password를 입력하여 진행하고, Resource 인가 작업은 App에서 요청한 Scope 정보를 보여주는 방식으로 진행된다.
* 8, 9 : User Agent는 인증, 인가 정보를 Auth Sever에게 전달하여 **Auth Code**와 App으로 돌아갈 App URL을 전달 받는다. Auth Code는 추후 Access/Refresh Token을 얻기 위한 임시 Token이다. Auth Code도 Return URL의 URL Query 형태로 전달된다.
* 10,11,12 : User Agent는 App의 Return URL로 이동한다. App은 URL Query를 통해서 Auth Code를 얻은 다음, 얻은 Auth Code 그리고 Client ID, Client Secret을 통해 Resource에 접근 할 수 있는 Access Token과 Access Token을 새로 받을때 이용하는 Refresh Token을 발급 받는다.

![[그림 4] Google OAuth 2.0 Authorization UI]({{site.baseurl}}/images/theory_analysis/OAuth_2.0/Auth_Google_UI.PNG){: width="600px"}

[그림 4]는 Google의 Authorization UI를 이용하여 User 인증 및 Resource 인가를 수행하는 과정을 나타내고 있다. Login을 수행하고 App이 요청한 인가 Scope 정보를 User에게 물어봐 동의를 구한다.

#### 1.3. Resource 접근

![[그림 5] OAuth2.0 Resource 접근]({{site.baseurl}}/images/theory_analysis/OAuth_2.0/OAuth_2.0_Resource_Access_Flow.PNG)

[그림 5]는 App에서 발급 받은 Access Token을 이용하여 Resource에 접근하는 과정을 나타내고 있다.

* 1,2 : User는 User Agent를 통해서 Resource를 요청한다.
* 3,4 : App은 발급받은 Access Token을 이용하여 Resource 요청과 함께 Access Token도 같이 전달한다.
* 5,6 : Resource Server는 Access Token이 유효한지 확인한 후 App에게 Resource를 전달한다.
* 7,8 : App은 User Agent를 통해서 User에게 Resource를 전달한다.

#### 1.4. Refresh Token

Resource Token은 App이 이용하던 Access Token이 Timeout되어 Invaild 상태가 되었을경우 **새로운 Access Token**을 발급받기 위해 이용되는 Token이다. Authorization Server는 App에게 Access Token을 **처음** 발급 할 때만 Refresh Token을 같이 전달한다. 따라서 App은 Refresh Token을 저장하고 이용해야 한다. Authorization Server는 Refresh Token을 반드시 전송할 필요 없다. Refresh Token이 없는 App은 Access Token이 Invaild한 상태가 되면 User에게 요청하여 다시 Access Token을 발급 받아야 한다. Refresh Token은 **Bearer Token**이라고도 불린다. [그림 6]은 App이 Refresh Token을 이용하는 과정을 나타낸다.

![[그림 6] Refresh Token 이용 과정]({{site.baseurl}}/images/theory_analysis/OAuth_2.0/OAuth_2.0_Refresh_Token_Flow.PNG)

[그림 6]은 Refresh Token을 이용하는 과정을 나타내고 있다.

* 1,2,3 : App은 User의 요청을 받아 Access Token을 이용하여 Resource Server에게 Resource를 요청한다.
* 4,5 : Resource Server는 Authorization Server에게 Access Token이 유요한지 물어본다.
* 6,7,8 : App이 Access Token이 Invaild 하다는 결과를 받으면 Authorization Server에게 Refresh Token을 이용하여 새로운 Access Token을 받는다.
* 9 ~ 14 : App은 새로 받은 Access Token과 Client ID, Client Secret을 이용하여 다시 Resource를 요청하고, 받은 Resource를 User Agent를 통해서 Agent에게 전달한다.

### 2. 참조

* [http://jlabusch.github.io/oauth2-server/index.html](http://jlabusch.github.io/oauth2-server/index.html)
* [https://opentutorials.org/course/2473/16571](https://opentutorials.org/course/2473/16571)
* [https://db-blog.web.cern.ch/blog/luis-rodriguez-fernandez/2017-04-oracle-jet-ords-oauth2](https://db-blog.web.cern.ch/blog/luis-rodriguez-fernandez/2017-04-oracle-jet-ords-oauth2)
* [https://www.oauth.com/oauth2-servers/client-registration/client-id-secret/](https://www.oauth.com/oauth2-servers/client-registration/client-id-secret/)
* [https://medium.com/@pumudu88/google-oauth2-api-explained-dbb84ff97079](https://medium.com/@pumudu88/google-oauth2-api-explained-dbb84ff97079)
* [http://tutorials.jenkov.com/oauth2/authorization.html](http://tutorials.jenkov.com/oauth2/authorization.html)
* [https://help.memberclicks.com/hc/en-us/articles/230536287-API-Authorization](https://help.memberclicks.com/hc/en-us/articles/230536287-API-Authorization)