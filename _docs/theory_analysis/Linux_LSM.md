---
title: Linux LSM (Linux Security Module)
category: Theory, Analysis
date: 2017-01-14T12:00:00Z
lastmod: 2017-01-15T12:00:00Z
comment: true
adsense: true
---

Linux의 Security Framework인 LSM(Linux Security Module)을 분석한다.

### 1. LSM(Linux Security Module)

![]({{site.baseurl}}/images/theory_analysis/Linux_LSM/Linux_LSM_Framework.PNG){: width="300px"}

LSM은 Linux안에서 다양한 Security Module들의 구동 환경을 제공해주는 Security Framework이다. 현재 Linux의 Capability, SELinux, AppArmor, smack들의 기법들은 모두 LSM을 이용하고 있다.

Linux Document에는 LSM을 Framework라고 명시하지만, 실제로 LSM은 Linux Kernel Code 곳곳에 **Hook**을 넣어 Linux Kernel이 Security Module의 함수를 호출할 수 있게 만드는 **Interface** 역활만을 수행한다. 따라서 LSM은 Security 정책을 전적으로 Security Module에 의존하게 된다.

![]({{site.baseurl}}/images/theory_analysis/Linux_LSM/Linux_LSM_Query.PNG){: width="600px"}

위의 그림은 LSM의 실제 동작을 간략하게 나타내고 있다. Linux Kernel은 Application이나 Device의 여러 요청들을 처리하면서 중간중간 LSM의 Hook을 만나게 된다. Linux Kernel은 Hook을 거치면서 Security Module의 Hook Function을 수행한다. 수행 결과는 오직 YES/No로 받는다. Yes를 받계 되면 계속해서 요청을 처리하고, No를 받게 되면 요청 처리를 멈춘다.

LSM 위에 올라가는 Security Module은 lsmod 명령으로 조회가능한 Loadable Module이 아니다. 따라서 Security Module은 반드시 Kernel Compile시 같이 Compile되어야 한다. 일부 Security Module은 같이 Compile 되었어도 Booting 설정을 통해 이용 유무를 설정 할 수 있다.

#### 1.1. LSM with System Call

![]({{site.baseurl}}/images/theory_analysis/Linux_LSM/Linux_LSM_System_Call.PNG)

LSM의 Hook은 System Call을 처리하면서 가장 많이 만나게 된다. 위의 그림은 Linux Kernel의 System Call을 처리 과정중 LSM의 Hook의 처리 위치를 나타내고 있다. LSM의 Hook은 System Call 함수안에 위치한다. 또한 open(), read(), write() System Call 처럼 파일의 Owner, Group을 따지는 DAC(Discretionary Access Control)은 LSM의 Hook전에 수행한다.

#### 1.2. LSM Module Stack, Hook Head

![]({{site.baseurl}}/images/theory_analysis/Linux_LSM/Linux_LSM_Stack.PNG){: width="250px"}

LSM 위에 다양한 Security Module들을 동시에 올릴 수 있다. 이러한 기법을 Module Stacking이라고 명칭한다. 위의 그림은 Capability Module, Yama Module, AppArmor Module이 순서대로 LSM 위에 올라간 그림을 나타내고 있다.

![]({{site.baseurl}}/images/theory_analysis/Linux_LSM/Linux_LSM_Function_Pointer.PNG)

위의 그림은 여러개의 Security Module들이 실제로 LSM 위에 어떤 방법으로 올라가는지를 나타내고 있다. LSM은 **security_hook_heads**라는 Struct를 가지고 있다. security_hook_heads는 각 Security Module의 Hook Function으로 연결되는 Linked List의 Head(Hook Head)들을 가지고 있다. 그림에서는 task_ptr, task_free, ptrace_access_check같은 몇개의 Hook Head만을 나타냈지만 실제로 security_hook_heads는 LSM의 Hook 개수만큼의 Hook Head를 가지고 있다.

LSM에 올라온 Security Module의 순서대로 Security Module의 Hook Function들이 Hook Head에 연결된다. Capability Module, Yama Module, AppArmor Module 순으로 LSM에 올라갔기 때문에 ptrace_access_check Hook Head에 Capabilty, Yama, AppArmor의 ptrace_access_check Hook Function이 순서대로 연결된다. task_ptr Hook Head에는 Capability와 Yama의 Hook Function만 연결되어 있는데 AppArmor는 task_ptr Hook Function을 구현하지 않았기 때문이다.

먼저 LSM에 올라온 Security Module의 Hook Function이 먼져 수행되고 중간 Hook Function의 결과가 No라면 그 즉시 다음 Hook Function을 수행하지 않고 중단한다. 위의 그림처럼 Security Module이 설정되어 있는 상태에서 ptrace_access_check hook이 발생하면 가장 먼져 Capability의 ptrace_access_check Hook Function이 실행된다. Capability의 ptrace_access_check Hook Function의 결과가 Yes라면 Yama의 ptrace_access_check Hook Function이 수행된다. 만약 결과가 No라면 다음 Yama의 Hook Function을 수행하지 않고 바로 LSM을 빠져 나온다.

{% highlight C linenos %}
/**
 * security_init - initializes the security framework
 *
 * This should be called early in the kernel initialization sequence.
 */
int __init security_init(void)
{
	int i;
	struct list_head *list = (struct list_head *) &security_hook_heads;

	for (i = 0; i < sizeof(security_hook_heads) / sizeof(struct list_head);
	     i++)
		INIT_LIST_HEAD(&list[i]);
	pr_info("Security Framework initialized\n");

	/*
	 * Load minor LSMs, with the capability module always first.
	 */
	capability_add_hooks();
	yama_add_hooks();
	loadpin_add_hooks();

	/*
	 * Load all the remaining security modules.
	 */
	do_security_initcalls();

	return 0;
}
{% endhighlight %}

위의 Code는 LSM의 초기화 함수이다. 19 ~ 21줄에서 Capability, Yama 순으로 LSM에 올라가는 것을 확인 할 수 있다. 26줄에서 나머지 Security Module들이 LSM에 올라간다.

### 2. 참조

* Linux Document - [https://www.kernel.org/doc/Documentation/security/LSM.txt](https://www.kernel.org/doc/Documentation/security/LSM.txt)
* Linux Security Module Framework - [http://www.kroah.com/linux/talks/ols_2002_lsm_paper/lsm.pdf](http://www.kroah.com/linux/talks/ols_2002_lsm_paper/lsm.pdf)
* Linux Security Modules:
General Security Support for the Linux Kernel - [http://www.kroah.com/linux/talks/usenix_security_2002_lsm_paper/lsm.pdf](http://www.kroah.com/linux/talks/usenix_security_2002_lsm_paper/lsm.pdf)
