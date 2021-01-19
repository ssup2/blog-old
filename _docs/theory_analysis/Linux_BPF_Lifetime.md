---
title: Linux BPF (Berkeley Packet Filter) Lifetime
category: Theory, Analysis
date: 2018-12-30T12:00:00Z
lastmod: 2018-12-30T12:00:00Z
comment: true
adsense: true
---

Linux의 BPF Program 및 BPF Map의 Lifetime을 분석한다.

### 1. Linux BPF Lifetime

{% highlight c %}
int bpf(int cmd, union bpf_attr *attr, unsigned int size)
{% endhighlight %}
<figure>
<figcaption class="caption">[함수 1] bpf() System Call</figcaption>
</figure>

Linux의 BPF Program 및 BPF Map은 bpf() System Call을 통해서 생성하고 제어한다. [함수 1]은 bpf() System Call을 나타내고 있다. bpf() System Call의 cmd Parameter에 "BPF_PROG_LOAD"을 설정하여 호출하면 BPF Program을 Loading하고, cmd Parameter에 "BPF_MAP_CREATE"을 설정하여 호출하면 BPF Map을 생성한다. bpf() System Call은 File Descriptor를 반환한다. 따라서 bpf() System Call을 호출한 App(Process)은 Loading된 BPF Program 또는 생성된 BPF Map을 bpf() System Call이 반환하는 File Descrptor를 통해서 제어한다.

App(Process)이 bpf() System Call 호출을 통해서 Loading한 BPF Program 및 생성한 BPF Map은 App이 종료되면서 같이 제거된다. 여기에는 예외 사항이 존재하는데, 대표적인 예로는 tc 명령어를 통해서 Loading한 BPF Program이 존재한다. tc 명령어는 SCHED_CLS, SCHED_ACT Type의 BPF Program을 Loading/Unloading 하는 기능을 제공하고 있는데, tc 명령어를 통해서 Loading한 BPF Program은 tc 명령어(Process)가 종료 되더라도 제거되지 않는다. 이유는 Linux Kernel 내부의 tc Subsystem이 tc 명령어를 통해서 Loading한 BPF Program이 제거되지 않도록 참조하고 있기 때문이다.

App이 bpf() System Call 호출을 통해서 Loading한 BPF Program 및 생성한 BPF Map이 App이 종료가 되면서 같이 제거가 되는것을 막기 위해서는 BPFFS (BPF Filesystem)을 이용하여 **Pinning**하면 된다. cmd Parameter에 "BPF_OBJ_PIN"을 설정하고, attr Parameter에 Pinning될 BPF Program 및 BPF Map의 File Descriptor와 Pinning될 Path(위치)를 넣어주고 bpf() System Call을 호출하면 된다. 여기서 Path는 반드시 BPFFS에 포함된 Path가 되어야 한다. Pinning된 BPF Program 및 BPF Map의 File Descriptor는 cmd Parameter에 "BPF_OBJ_GET"을 설정하고, attr Parameter에 Path를 넣어서 bpf() System Call을 호출하여 얻을수 있다.

{% highlight shell %}
# mount -t bpf bpf /sys/fs/bpf
# mount | grep bpf
none on /sys/fs/bpf type bpf (rw,relatime)
{% endhighlight %}
<figure>
<figcaption class="caption">[Shell 1] bpffs mount</figcaption>
</figure>

BPFFS은 BPF Program 및 BPF Map의 Pinning을 위한 특수 Filesystem이며, systemd를 이용하는 환경에서는 일반적으로 설정을 통해서 "/sys/fs/bpf" Path에 기본적으로 Mount 되어 있도록 설정할 수 있다. [Shell 1]의 명령어를 통해서 직접 Mount를 수행할 수도 있다.

### 2. 참조

* BPF System Call : [https://man7.org/linux/man-pages/man2/bpf.2.html](https://man7.org/linux/man-pages/man2/bpf.2.html)
* BPFFS : [https://facebookmicrosites.github.io/bpf/blog/2018/08/31/object-lifetime.html](https://facebookmicrosites.github.io/bpf/blog/2018/08/31/object-lifetime.html)
* BPFFS : [https://github.com/cilium/cilium/blob/v1.7.12/bpf/init.sh](https://github.com/cilium/cilium/blob/v1.7.12/bpf/init.sh)
* BPFFS : [https://github.com/cilium/cilium/blob/v1.7.12/pkg/bpf/bpf_linux.go#L291](https://github.com/cilium/cilium/blob/v1.7.12/pkg/bpf/bpf_linux.go#L291)
* BPFFS : [https://www.ferrisellis.com/content/ebpf_syscall_and_maps/](https://www.ferrisellis.com/content/ebpf_syscall_and_maps/)
