---
title: Visual Studio Code 설치, 설정, 사용 / Windows 10 환경
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

### 1. 설치, 설정 환경

설치, 설정 환경은 다음과 같다.
* Windows 10 Pro 64bit
  * Hyper-V를 이용하기 위해서는 Pro 이상의 Version이 필요하다.
  * Bios에서 Virtualization 기능을 ON해야 한다.
  * WSL (Windosws Subsystem for Linux)를 이용하기 위해서 Windows를 Update한다.

### 2. Docker for Windows 설치

Visual Studio Code의 Terminal에서 Docker 이용을 위한 Docker for Windows를 설치한다.
* [https://docs.docker.com/docker-for-windows](https://docs.docker.com/docker-for-windows)

![[그림 1] Docker for Windows 설치]({{site.baseurl}}/images/record/Visual_Studio_Code_Install_Windows_10/Docker_Install_01.PNG){: width="550px"}

[그림 1]과 같이 설치 완료후 Docker for Windows를 실행하여 Hyper-V를 활성화한다. Docker for Windows는 Hyper-V로 생성한 VM에서 Docker를 실행하는 구조이다.

![[그림 2] Docker Port 설정]({{site.baseurl}}/images/record/Visual_Studio_Code_Install_Windows_10/Docker_Install_02.PNG){: width="550px"}

[그림 2]와 같이 WSL Ubuntu에서 Docker에 접근할 수 있도록 Docker Daemon을 2375 Port로 개방한다.

~~~console
> route add  172.17.0.0 MASK 255.255.0.0 10.0.75.2
~~~

Windows에서 Container의 IP에 바로 접근할 수 있도록 Routing Rule을 추가한다. Default Docker Network인 172.17.0.0/24 Network 관련 Routing Rule을 추가한다. PowerShell을 관리자 권한으로 실행하여 아래의 명령어를 실행한다.

### 3. WSL Ubuntu 설치

![[그림 4] 개발자 모드 설정]({{site.baseurl}}/images/record/Visual_Studio_Code_Install_Windows_10/Developer_Mode.PNG){: width="500px"}

WSL (Windows Subsystem for Linux) Bash를 활성화한다. 개발자 기능 사용을 검색하여 실행한다. [그림 4]와 같이 **개발자 모드**로 변경한다.

![[그림 5] WSL 기능 활성화]({{site.baseurl}}/images/record/Visual_Studio_Code_Install_Windows_10/WSL_Enable.PNG){: width="400px"}

[그림 5]와 같이 Windows 기능에서 WSL을 활성화 한다.

![[그림 6] WSL Ubuntu 설치]({{site.baseurl}}/images/record/Visual_Studio_Code_Install_Windows_10/Ubuntu_Install.PNG){: width="500px"}

WSL Ubuntu 설치한다. [그림 6]과 같이 Store에서 Ubuntu를 검색하여 설치하고 재부팅한다.

~~~console
$ sudo passwd root
Enter new UNIX password:
Retype new UNIX password:
passwd: password updated successfully
~~~

WSL Ubuntu의 root 계정을 생성한다. WSL Ubuntu를 설치 후 처음으로 실행하면 WSL Ubuntu에서 이용할 User와 Password를 입력 받는다. WSL Ubuntu에서 위의 명령를 실행한다.

~~~console
> ubuntu config --default-user root
~~~

WSL Ubuntu가 Default 계정으로 root를 이용하도록 설정한다. WSL Ubuntu를 종료한 다음, PowerShell을 관리자 권한으로 실행하여 위의 명령어를 실행한다.

~~~console
# apt update
# apt install docker.io
# apt install docker-compose
# echo "export DOCKER_HOST=tcp://localhost:2375" >> ~/.bashrc && source ~/.bashrc
~~~

Docker, Docker Compose 설치 및 설정한다. WSL Ubuntu를 실행하여 Docker Client를 위해서 Docker Package를 설치한다. Docker for Windows의 Docker와 연결하기 위해서 Bash에 Docker Host를 지정한다. WSL Ubuntu에서 위의 명령어를 입력한다.

~~~console
# apt install git
# git config --global core.autocrlf input
~~~

git Client를 설치한다. git Client가 CRLF를 LF로 자동으로 변경하도록 설정한다. WSL Ubuntu에서 위의 명령어를 입력한다.

### 4. Visual Studio Code 설치, 설정

Visual Studio Code를 설치한다.
* https://code.visualstudio.com/

Visual Studio Code의 Default Shell을 WSL Ubuntu로 바꾼다. **Ctrl + Shift + P**를 눌러 Command Palatte를 실행하고 Terminal: Select Default Shell을 선택한 다음 WSL Ubuntu를 선택한다.

### 5. 사용법

### 6. 참조

* [https://nickjanetakis.com/blog/setting-up-docker-for-windows-and-wsl-to-work-flawlessly](https://nickjanetakis.com/blog/setting-up-docker-for-windows-and-wsl-to-work-flawlessly)
* [https://forums.docker.com/t/connecting-to-containers-ip-address/18817](https://forums.docker.com/t/connecting-to-containers-ip-address/18817)
* [https://webdir.tistory.com/543](https://webdir.tistory.com/543)