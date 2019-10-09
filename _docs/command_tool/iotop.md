---
title: iotop
category: Command, Tool
date: 2019-10-09T12:00:00Z
lastmod: 2019-10-09T12:00:00Z
comment: true
adsense: true
---

Thread들을 Block I/O Bandwidth가 높은 순서대로 출력하는 iotop의 사용법을 정리한다.

***

* TOC
{:toc}

***

### 1. iotop

#### 1.1. # iotop

{% highlight console %}
# iotop
Total DISK READ :       3.92 K/s | Total DISK WRITE :      16.62 M/s
Actual DISK READ:       3.92 K/s | Actual DISK WRITE:      16.82 M/s
  TID  PRIO  USER     DISK READ  DISK WRITE  SWAPIN     IO>    COMMAND
  355 be/3 root        0.00 B/s   11.76 K/s  0.00 % 67.29 % [jbd2/sda2-8]
 3769 be/4 42472       0.00 B/s   14.63 M/s  0.00 % 16.19 % prometheus -config.file /etc/prometheus/prometheus~gger:stdout -storage.local.path /var/lib/prometheus
 3589 be/4 42472       3.92 K/s    0.00 B/s  0.00 %  8.77 % prometheus -config.file /etc/prometheus/prometheus~gger:stdout -storage.local.path /var/lib/prometheus
 5425 be/4 42472       0.00 B/s 2026.53 K/s  0.00 %  3.80 % prometheus -config.file /etc/prometheus/prometheus~gger:stdout -storage.local.path /var/lib/prometheus
 8071 be/4 root        0.00 B/s    0.00 B/s  0.00 %  0.08 % [kworker/u4:3]
    1 be/4 root        0.00 B/s    0.00 B/s  0.00 %  0.00 % systemd --system --deserialize 40
    2 be/4 root        0.00 B/s    0.00 B/s  0.00 %  0.00 % [kthreadd]
    4 be/0 root        0.00 B/s    0.00 B/s  0.00 %  0.00 % [kworker/0:0H]
    6 be/0 root        0.00 B/s    0.00 B/s  0.00 %  0.00 % [mm_percpu_wq]     
{% endhighlight %}
<figure>
<figcaption class="caption">[Shell 1] iotop</figcaption>
</figure>

[Shell 1]은 iotop 명령어를 통해서 확인할 수 있는 Shell의 모습을 나타내고 있다. 윗 부분은 평균 Block I/O Bandwidth를 출력하고, 아랫 부분은 Process별 Block I/O Bandwidth를 출력한다. 윗 부분의 Total은 Kernel의 Block Device Subsystem의 Kernel Thread들과 나머지 Process/Thread들 사이에 주고 받는 Data를 의미한다. Actual은 Kernel의 Block Device Subsystem의 Kernel Thread들과 실제 Block Disk들 사이에 주고 받은 Data를 의미한다.
