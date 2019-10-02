---
title: pidstat
category: Command, Tool
date: 2019-09-14T12:00:00Z
lastmod: 2019-09-14T12:00:00Z
comment: true
adsense: true
---

process별 Resource 사용량을 출력하는 pidstat의 사용법을 정리한다.

### 1. pidstat

#### 1.1. # pidstat (-u)

{% highlight console %}
# pidstat
Linux 4.15.0-60-generic (node09)        10/02/19        _x86_64_        (2 CPU)

15:23:24      UID       PID    %usr %system  %guest   %wait    %CPU   CPU  Command
15:23:24        0         1    0.02    0.01    0.00    0.00    0.03     1  systemd
15:23:24        0         2    0.00    0.00    0.00    0.00    0.00     1  kthreadd
15:23:24        0         7    0.00    0.02    0.00    0.01    0.02     0  ksoftirqd/0
15:23:24        0         8    0.00    0.17    0.00    0.15    0.17     0  rcu_sched
15:23:24        0        10    0.00    0.00    0.00    0.00    0.00     0  migration/0
15:23:24        0        11    0.00    0.00    0.00    0.00    0.00     0  watchdog/0
15:23:24        0        14    0.00    0.00    0.00    0.00    0.00     1  watchdog/1
{% endhighlight %}
<figure>
<figcaption class="caption">[Shell 1] pidstat</figcaption>
</figure>

CPU 사용량을 출력한다.

#### 1.2. # pidstat -t

{% highlight console %}
# pidstat -t
Linux 4.15.0-60-generic (node09)        10/02/19        _x86_64_        (2 CPU)

15:31:32      UID      TGID       TID    %usr %system  %guest   %wait    %CPU   CPU  Command
15:31:32        0         1         -    0.02    0.01    0.00    0.00    0.03     1  systemd
15:31:32        0         -         1    0.02    0.01    0.00    0.00    0.03     1  |__systemd
15:31:32        0         2         -    0.00    0.00    0.00    0.00    0.00     0  kthreadd
15:31:32        0         -         2    0.00    0.00    0.00    0.00    0.00     0  |__kthreadd
15:31:32        0         7         -    0.00    0.02    0.00    0.01    0.02     0  ksoftirqd/0
15:31:32        0         -         7    0.00    0.02    0.00    0.01    0.02     0  |__ksoftirqd/0
15:31:32        0         8         -    0.00    0.17    0.00    0.15    0.17     0  rcu_sched
15:31:32        0         -         8    0.00    0.17    0.00    0.15    0.17     0  |__rcu_sched
15:31:32        0        10         -    0.00    0.00    0.00    0.00    0.00     0  migration/0
15:31:32        0         -        10    0.00    0.00    0.00    0.00    0.00     0  |__migration/0
15:31:32        0        11         -    0.00    0.00    0.00    0.00    0.00     0  watchdog/0
15:31:32        0         -        11    0.00    0.00    0.00    0.00    0.00     0  |__watchdog/0
15:31:32        0        14         -    0.00    0.00    0.00    0.00    0.00     1  watchdog/1
15:31:32        0         -        14    0.00    0.00    0.00    0.00    0.00     1  |__watchdog/1
{% endhighlight %}
<figure>
<figcaption class="caption">[Shell 2] pidstat -t</figcaption>
</figure>

#### 1.3. # pidstat [Interval] [Count]

Interval 간격으로 Count 횟수 만큼 CPU 사용량을 출력한다.

#### 1.4. # pidstat -p [PID] [Interval]

Interval 간격으로 [PID] Process의 CPU 사용량을 출력한다.

#### 1.5. # pidstat -d

{% highlight console %}
# pidstat -d
Linux 4.15.0-60-generic (node09)        10/02/19        _x86_64_        (2 CPU)

15:43:32      UID       PID   kB_rd/s   kB_wr/s kB_ccwr/s iodelay  Command
15:43:32        0         1     10.55     39.65      6.66     962  systemd
15:43:32        0        27      0.00      0.00      0.00      45  writeback
15:43:32        0       355      0.00     26.71      0.00 7489695  jbd2/sda2-8
15:43:32        0       436      0.00      0.00      0.00      28  lvmetad
15:43:32        0       522      0.07      0.00      0.00     452  loop0
{% endhighlight %}
<figure>
<figcaption class="caption">[Shell 3] pidstat -d</figcaption>
</figure>

Disk I/O 사용량을 출력한다.

#### 1.6. # pidstat -r

{% highlight console %}
# pidstat -r
Linux 4.15.0-60-generic (node09)        10/02/19        _x86_64_        (2 CPU)

15:44:13      UID       PID  minflt/s  majflt/s     VSZ     RSS   %MEM  Command
15:44:13        0         1      0.22      0.00  160180    9652   0.12  systemd
15:44:13        0       436      0.00      0.00  105904    1720   0.02  lvmetad
15:44:13        0       925      0.02      0.00   30028    3268   0.04  cron
15:44:13        0       934      0.00      0.00   62132    5540   0.07  systemd-logind
15:44:13        0       960      0.00      0.00  310152    2720   0.03  lxcfs 
{% endhighlight %}
<figure>
<figcaption class="caption">[Shell 4] pidstat -r</figcaption>
</figure>

Memory 사용량을 출력한다.

#### 1.7. # pidstat -s

{% highlight console %}
# pidstat -s
Linux 4.15.0-60-generic (node09)        10/02/19        _x86_64_        (2 CPU)

15:45:02      UID       PID StkSize  StkRef  Command
15:45:02        0         1     132      56  systemd
15:45:02        0       436     132      12  lvmetad
15:45:02        0       925     132      28  cron
15:45:02        0       934     132      16  systemd-logind
15:45:02        0       960     132      24  lxcfs 
{% endhighlight %}
<figure>
<figcaption class="caption">[Shell 5] pidstat -s</figcaption>
</figure>

Stack 사용량을 출력한다.

#### 1.8. # pidstat -v

{% highlight console %}
# pidstat -v
Linux 4.15.0-60-generic (node09)        10/02/19        _x86_64_        (2 CPU)

15:45:34      UID       PID threads   fd-nr  Command
15:45:34        0         1       1      82  systemd
15:45:34        0         2       1       0  kthreadd
15:45:34        0         4       1       0  kworker/0:0H
15:45:34        0         6       1       0  mm_percpu_wq
15:45:34        0         7       1       0  ksoftirqd/0 
{% endhighlight %}
<figure>
<figcaption class="caption">[Shell 6] pidstat -v</figcaption>
</figure>

Kernel Table (User, Thread Count, FD Count) 정보를 출력한다.

#### 1.9. # pidstat -w

{% highlight console %}
# pidstat -w
Linux 4.15.0-60-generic (node09)        10/02/19        _x86_64_        (2 CPU)

15:47:23      UID       PID   cswch/s nvcswch/s  Command
15:47:23        0         1      0.25      0.05  systemd
15:47:23        0         2      0.01      0.00  kthreadd
15:47:23        0         4      0.00      0.00  kworker/0:0H
15:47:23        0         6      0.00      0.00  mm_percpu_wq
15:47:23        0         7      5.16      1.68  ksoftirqd/0 
{% endhighlight %}
<figure>
<figcaption class="caption">[Shell 7] pidstat -w</figcaption>
</figure>

Context Switch 정보를 출력한다.
