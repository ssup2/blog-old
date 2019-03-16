---
title: Visual Studio Code 설치, 설정, 사용 - Windows 10
category: Record
date: 2019-03-14T12:00:00Z
lastmod: 2019-03-14T12:00:00Z
comment: true
adsense: true
---

***

* TOC
{:toc}

***

### 1. 환경

* Windows 10 Pro 64bit
  * Hyper-V를 이용하기 위해서는 Pro 이상의 Version이 필요하다.
  * Bios에서 Virtualization 기능을 ON해야 한다.
  * WSL (Windosws Subsystem for Linux)를 이용하기 위해서 Windows를 Update한다.

### 2. Docker for Windows 설치

* Visual Studio Code의 Terminal에서 Docker 이용을 위한 Docker for Windows를 설치한다.
  * [https://docs.docker.com/docker-for-windows](https://docs.docker.com/docker-for-windows)

* 설치 완료후 Docker for Windows를 실행하여 Hyper-V를 활성화한다.
  * Docker for Windows는 Hyper-V로 생성한 VM에서 Docker를 실행하는 구조이다.

![]({{site.baseurl}}/images/record/Visual_Studio_Code_Install_Windows_10/Docker_Install.PNG){: width="500px"}

### 3. Git 설치

* 아래와 같이 선택하여 Unix Tool을 설치한다.

![]({{site.baseurl}}/images/record/Visual_Studio_Code_Install_Windows_10/Git_Install_01.PNG){: width="500px"}

* 아래와 같은 End of Line 정책을 선택한다.

![]({{site.baseurl}}/images/record/Visual_Studio_Code_Install_Windows_10/Git_Install_02.PNG){: width="500px"}

* 나머지는 기본값으로 설정하여 설치한다.

### 4. Ubuntu WSL 설치

* WSL (Windosws Subsystem for Linux) Bash를 활성화한다.
  * 개발자 기능 사용을 검색하여 실행한다.
  * 아래와 같이 **개발자 모드**로 변경한다.

![]({{site.baseurl}}/images/record/Visual_Studio_Code_Install_Windows_10/Developer_Mode.PNG){: width="500px"}

* Windows 기능에서 WSL을 활성화 한다.

![]({{site.baseurl}}/images/record/Visual_Studio_Code_Install_Windows_10/WSL_Enable.PNG){: width="500px"}

* WSL Ubuntu 설치
  * Store에서 Ubuntu를 검색하여 설치하고 재부팅한다.

![]({{site.baseurl}}/images/record/Visual_Studio_Code_Install_Windows_10/Ubuntu_Install.PNG){: width="500px"}

### 5. Visual Studio Code 설치, 설정

### 6. 사용법
