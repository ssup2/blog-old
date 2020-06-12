---
title: GitOps
category: Theory, Analysis
date: 2020-06-08T12:00:00Z
lastmod: 2020-06-08T12:00:00Z
comment: true
adsense: true
---

GitOps를 분석한다.

### 1. GitOps

![[그림 1] GitOps Pipeline]({{site.baseurl}}/images/theory_analysis/GitOps/GitOps_Pipeline.PNG)

GitOps는 Git을 App 개발뿐만 아니라 App Delivery 즉 App 배포에도 활용하는 기법을 의미한다. [그림 1]은 GitOps의 Pipeline을 나타내고 있다. App Code를 관리하는 Application Git Repo와 배포를 관리하는 Deployment Git Repo, 2가지의 Git Repo가 존재한다. 

App 개발자가 Application Git Repo에 Code를 Commit하면, Application Git Repo는 Container Image Builer에게 Hook을 전송하여 Commit된 Code를 반영한 새로운 Container App Image를 생성하도록 한다. Container Image Builder는 Container App Image를 생성하고 Container Image Repo에 Container App Image를 Push한 다음, Config Updater에게 새로 생성된 Container App Image의 정보를 전달한다.

Config Updater는 Deployment Git Repo에 새로 생성된 Container App Image의 내용을 반영하여 Commit한다. Deployment Git Repo는 실제 배포를 담당하는 Deploy Operator에게 Hook을 전달하여, 새로 생성된 Container App Image가 Deploy Operator에 의해서 실제 배포되도록 한다. App 배포를 담당하는 사람이 Deployment Git Repo에 직접 Commit하여 배포 설정을 변경 하는것도 가능하다.

Deployment Git Repo에 있는 배포 설정은 선언적으로 (Declaratively) 정의되어 있어야 하고, Deploy Operator가 App의 장애를 파악할 수 있도록 설정되어 있어야 한다. 그래야 Deploy Operator가 App의 장애를 파악하고, 배포 설정과 실제 배포 내용이 일치하도록 계속 배포를 시도할 수 있기 때문이다. GitOps를 이용하면 배포 설정도 Git으로 관리되기 때문에, 자연스럽게 배포 History도 관리된다는 장점을 갖고 있다.

### 2. 참조

* [https://www.weave.works/technologies/gitops/](https://www.weave.works/technologies/gitops/)
* [https://www.weave.works/blog/automate-kubernetes-with-gitops](https://www.weave.works/blog/automate-kubernetes-with-gitops)
* [https://cloud.google.com/kubernetes-engine/docs/tutorials/gitops-cloud-build](https://cloud.google.com/kubernetes-engine/docs/tutorials/gitops-cloud-build)
