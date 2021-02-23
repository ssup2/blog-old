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

Git Flow는 Git으로 Project를 관리시 Branch를 어떻게 나누고 관리할지를 정하는 Branch 전략을 의미한다. [그림 1]은 Git Flow에서 이용하는 Branch들을 나타내고 있다. Git Flow에서는 Master, Develop의 **Main Branch**와 나머지 Feature, Release, Hotfix의 **Supporting Branch**로 분류한다. Main Branch는 Project의 시작과 동시에 영원히 존재하는 Branch를 의미하고 Supporting Branch는 필요에 따라서 생성/소멸되는 Branch를 의미한다. [그림 1]에서 수평 점선은 Supporting Branch가 생성되고 제거되는 시점을 나타낸다.

#### 1.1. Main Branch

Main Branch의 Master Branch와 Develop Branch의 역할은 다음과 같다.

##### 1.1.1. Master Branch

Master Branch는 Release (Production에 투입된)된 Project의 형상을 갖고 있는 Branch를 의미한다. Master Branch의 각 Commit은 Version의 이름을 갖는 Tag로 관리된다. [그림 1]에서 Master Branch의 각 Commit 마다 Tag가 붙어있는 것을 확인할 수 있다. 일반적으로 Master Branch는 Release 준비가 완료된 Release Branch 또는 빠른 Bug 수정을 위한 Hotfix Branch와 Merge된다.

##### 1.1.2. Develop Branch

Develop Branch는 의미 그대로 개발이 진행되는 Project의 형상을 갖고 있는 Branch를 의미한다. 간단한 기능 개선/추가 관련 Commit 또는 수정이 급하지 않는 Bug 수정 Commit들은 모두 Develop Branch에 반영한다.

#### 1.2. Supporting Branch

Supporting Branch의 Feature, Release, Hotfix Branch의 역활은 다음과 같다.

##### 1.2.1. Feature

Feature Branch는 의미 그대로 주 기능 개발을 위해서 Develop Branch에서 파생되는 Branch이다. 현재 Develop Branch가 갖고 있는 Project의 형상(Code)에서 많은 부분의 변화가 필요하거나, 오랜 시간동안 개발이 필요한 경우 Develop Branch에 직접 Commit 하는것 보다는, Feature Branch를 생성하고 Feature Branch에 Commit 하는 방식을 권장한다.

개발하려는 각 주 기능마다 별도의 Feature Branch를 생성하는 방식을 권장하고 있다. [그림 1]에는 2개의 주 기능이 개발되는 과정을 나타내고 있다. 따라서 feature-a, feature-b 이름의 2개의 Feature Branch가 존재하는 것을 확인할 수 있다. Feature Branch는 개발이 완료되면 Develop Branch와 Merge되며 제거되거나, Develop Branch와의 Merge 이후 재활용되어 다음 Release를 위해서 이용될 수 있다.

##### 1.2.2. Release

Release Branch는 의미 그대로 Release가 되기 위한 Project의 형상을 갖고 있는 Branch이다. Develop Branch에서 파생되어 생성되며, Release Branch의 이름은 Relaese될 Version의 이름을 포함하여 'release-[version]'의 형태를 갖는다. [그림 1]에서 Release Branch의 이름이 'release-1.0'인 이유는, release-1.0 Branch가 Master Branch에 Merge된 이후에 v1.0 Version으로 Release될 목표로 생성되었기 때문이다.

Release Branch가 생성된 이후에는 수정이 급하지 않는 Bug 수정 Commit들은 Develop Branch에 먼저 반영 하는것이 아니라, Release Branch에 먼저 반영하고, 이후에 Develop Branch에 반영하여 Release Branch에서 관리되는 Project 형상의 완성도를 먼저 높이는 것을 권장하고 있다. Release Branch는 Release 준비가 완료되면 Master Branch와 Merge되며 제거된다.

##### 1.2.3. Hotfix

Hotfix Branch는 의미 그대로 빠른 Bug 수정을 위한 Branch이다. Master Branch에서 파생되어 생성되며, Hotfix Branch의 이름은 Release될 Version의 이름을 포함하여 'release-[version]'의 형태를 갖는다. [그림 1]에서 Hotfix Branch의 이름이 'hotfix-0.1.1'인 이유는, hotfix-0.1.1 Branch가 Master Branch에 Merge된 이후에 v0.1.1 Version으로 Release될 목표로 생성되었기 때문이다. Hotfix Branch는 Master Branch와 Merge된 이후에는 제거된다.

### 2. 참조

* [https://nvie.com/posts/a-successful-git-branching-model/](https://nvie.com/posts/a-successful-git-branching-model/)
