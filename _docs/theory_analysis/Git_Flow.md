---
title: Git Flow
category: Theory, Analysis
date: 2021-02-22T12:00:00Z
lastmod: 2021-02-22T12:00:00Z
comment: true
adsense: true
---

Git Flow를 분석한다.

### 1. Git Flow

![[그림 1] Git Flow]({{site.baseurl}}/images/theory_analysis/Git_Flow/Git_Flow.PNG){: width="700px"}

Git Flow는 Git으로 Project를 관리시 Branch를 어떻게 나누고 관리할지를 정하는 Branch 전략을 의미한다. [그림 1]은 Git Flow에서 이용하는 Branch들을 나타내고 있다. Git Flow에서는 Master, Develop의 **Main Branch**와 나머지 Feature, Release, Hotfix의 **Supporting Branch**로 분류한다. Main Branch는 Project의 시작과 동시에 영원히 존재하는 Branch를 의미하고 Supporting Branch는 필요에 따라서 생성/소멸되는 Branch를 의미한다.

#### 1.1. Main Branch

Main Branch의 Master Branch와 Develop Branch의 역할은 다음과 같다.

##### 1.1.1. Master Branch

Master Branch는 Release (Production에 투입된)된 Project의 형상을 갖고 있는 Branch를 의미한다. Master Branch의 각 Commit은 Version의 이름을 갖는 Tag로 관리된다. [그림 1]에서 Master Branch의 각 Commit 마다 Tag가 붙어있는 것을 확인할 수 있다. 일반적으로 Master Branch는 Release 준비가 완료된 Release Branch 또는 치명적인 Bug가 수정된 Hotfix Branch와 Merge된다.

##### 1.1.2. Develop Branch

Develop Branch는 의미 그대로 개발이 진행되는 Project의 형상을 갖고 있는 Branch를 의미한다. 간단한 기능 개발 Commit 또는 치명적이지 않은 Bug 수정 Commit들은 모두 Develop Branch에 반영한다.

#### 1.2. Supporting Branch

Supporting Branch의 Feature, Release, Hotfix Branch의 역활은 다음과 같다.

##### 1.2.1. Feature

Feature Branch는 의미 그대로 주 기능 개발을 위해서 Develop Branch에서 파생되는 Branch이다. 현재 Develop Branch가 갖고 있는 Project의 형상(Code)에서 많은 부분의 변화가 필요하거나, 오랜 시간동안 개발이 필요한 경우 Develop Branch에 직접 Commit 하는것 보다는, Feature Branch를 생성하고 Feature Branch에 Commit 하는 방식을 권장한다. 필요에 따라서는 Develop Branch와 중간에 Merge를 진행하면서 개발을 진행할 수 있다.

개발하려는 각 주 기능마다 별도의 Feature Branch를 생성하는 방식을 권장하고 있다. [그림 1]에는 2개의 주 기능이 개발되는 과정을 나타내고 있다. 따라서 feature-a, feature-b 이름의 2개의 Feature Branch가 존재하는 것을 확인할 수 있다. Feature Branch는 개발이 완료되면 Develop Branch와 Merge되며 제거된다.

##### 1.2.2. Release

##### 1.2.3. Hotfix

### 2. 참조

* [https://nvie.com/posts/a-successful-git-branching-model/](https://nvie.com/posts/a-successful-git-branching-model/)
