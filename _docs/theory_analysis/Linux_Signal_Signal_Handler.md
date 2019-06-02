---
title: Linux Signal, Signal Handler
category: Theory, Analysis
date: 2017-01-14T12:00:00Z
lastmod: 2017-01-15T12:00:00Z
comment: true
adsense: true
---

Linux의 Signal 및 Signal Handler를 분석한다.

### 1. Signal

| Signal | Default Action | 설명 |
|--------|----------------|------|
| SIGTERM | Term | Keyboard 입력으로 인한 Interrupt가 발생하였다. |
| SIGSEGV | Core | 잘못된 Memory 주소 참조로 인한 Segmentation Fault가 발생하였다. |
| SIGCHILD | Ign | Child Process가 종료되었다. |
| SIGKILL | Term | SIGKILL을 받은 Process를 강제 종료한다. |

<figure>
<figcaption class="caption">[표] 1] Linux Signal</figcaption>
</figure>

Linux에서 Signal은 Process에게 Event를 전달하는 대표적인 기법중 하나이다. [표 1]은 Linux에서 지원하는 몇가지 Signal들을 설명하고 있다. Signal을 전달받은 Process는 받은 Signal을 **Signal Mask**를 통해 무시하거나, 각 Signal마다 정의된 **Default Action**을 수행하여 Signal을 처리하거나, Process에 등록된 **Signal Handler**를 수행하여 Signal을 처리한다. 단 **SIGKILL**의 Signal Handler는 Process에 등록하지 못한다. SIGKILL을 받은 Process는 즉식 Linux Kernel에 의해서 강제로 죽기 때문이다. Default Action은 다음과 같이 Term, Stop, Core, Ign 4가지가 존재한다.

* Term (Terminate) : Process를 종료한다.
* Stop : Processs를 Paused 상태로 만든다.
* Core : Process를 종료하고 Core 파일을 남긴다.
* Ign (Ignore) : Signal을 무시한다.

### 2. Signal Handler

![[그림 1] Signal Handler 실행 과정]({{site.baseurl}}/images/theory_analysis/Linux_Signal_Signal_Handler/Linux_Signal_Handler_Process.PNG){: width="500px"}

[그림 1]은 Signal Handler의 실행 과정을 나타내고 있다. User Mode에서 App을 실행하던 Thread는 Trap 발생으로 인해 Kernel Mode에 진입하여 Trap을 처리한다. Trap 처리가 완료된 이후 Thread는 User Mode에 진입하기 전에 do_signal() 함수 호출을 통해 Thread의 Process가 전달받은 Signal이 있는지 확인한다. 전달받은 Signal이 있을경우 전달받은 Signal을 처리하는 Signal Handler가 등록되어있는지 확인한다. Signal Handler가 등록되어 있다면 setup_frame() 함수는 Thread의 User Mode Context가 저장되어 있는 Stack을 조작하여 Thread가 User Mode로 진입시 App이 아니라 Signal Handler가 실행되도록 만들고, Signal Handler 실행이 완료된 이후에는 sigreturn System Call을 호출하도록 만든다. 그 후 Thread는 User Mode로 진입한다.

User Mode로 진입한 Thread는 Thread의 User Mode Stack 조작으로 인해서 Signal Handler를 실행하고, sigreturn System Call을 호출하여 다시 Kenrel Mode로 진입한다. Kernel Mode로 진입한 Thread는 restore_sigcontext() 함수를 통해서 User Mode Stack을 setup_frame() 함수를 통해 변경되기 전의 상태로 만든다. 그 후 Thread는 User Mode로 진입하여 App을 실행한다.

#### 2.1. with Multithread

#### 2.2. signal() vs sigaction()

### 3. 참조

* Signal : [http://man7.org/linux/man-pages/man7/signal.7.html](http://man7.org/linux/man-pages/man7/signal.7.html)
* Signal Handler : Understanding the Linux Kernel
* Signal Handler : [https://www.joinc.co.kr/w/Site/system_programing/Book_LSP/ch06_Signal](https://www.joinc.co.kr/w/Site/system_programing/Book_LSP/ch06_Signal)
* Signal Handler : [https://devarea.com/linux-handling-signals-in-a-multithreaded-application/#.XKtY6JgzaiM](https://devarea.com/linux-handling-signals-in-a-multithreaded-application/#.XKtY6JgzaiM)
* Signal Handler : [http://egloos.zum.com/studyfoss/v/5182475](http://egloos.zum.com/studyfoss/v/5182475)
