---
title: Argo CD
category: Theory, Analysis
date: 2020-06-18T12:00:00Z
lastmod: 2020-06-18T12:00:00Z
comment: true
adsense: true
---

Argo CD를 분석한다.

### 1. Argo CD

![[그림 1] Argo CD Architecture]({{site.baseurl}}/images/theory_analysis/Argo_CD/Argo_CD_Architecture.PNG){: width="750px"}

Argo CD는 Kubernetes 기반 GitOps Platform이다. [그림 1]은 Argo CD의 Architecture를 나타내고 있다. Argo CD는 크게 API Server, Repo Server, Dex Server, Redis Server, Application Controller로 구성되어 있다.

API Server는 외부에서 Argo CD로 전달되는 모든 요청을 받는 창구 역활을 수행한다. App 관리자가 App의 배포 설정이 담겨있는 Kubernetes Manifest를 Deployment Git Repo에 Commit하면, Deployment Git Repo는 Commit Hook과 함께 변경된 Kubernetes Manifest를 API Server에게 전달한다. 또한 API Server는 Argo CD CLI 또는 CI/Workflow 도구들로부터 전송되는 Argo CD 설정 요청 및 App 수동 배포 요청들도 받는다.

Dex Server는 Argo CD의 인증 (Authentication)을 담당한다. Dex Server는 API Server에게 전달되는 Commit Hook 또는 App 배포 관련 요청들이 인증된 사용자 또는 도구들로부터 온 요청인지 확인한다. OICD, SAML, LDAP등 다양한 인증 Procotol/Format을 지원한다. Repo Server는 Deployment Git Repo에 저장되어 있는 Kubernetes Manifest를 Caching하고, Argo CD의 다른 구성요소들에게 Kubernetes Manifest를 제공하는 역활을 수행한다. Redis Server는 Argo CD 구성요소들의 Cache 역활을 수행한다.

### 2. 참조

* [https://argoproj.github.io/argo-cd/operator-manual/architecture/](https://argoproj.github.io/argo-cd/operator-manual/architecture/)
* [https://argoproj.github.io/argo-cd/operator-manual/user-management/](https://argoproj.github.io/argo-cd/operator-manual/user-management/)

