---
title: Prometheus Scaling, Federation
category: Theory, Analysis
date: 2020-01-13T12:00:00Z
lastmod: 2020-01-13T12:00:00Z
comment: true
adsense: true
---

Prometheus Federation을 분석한다.

### 1. Prometheus Scaling, Federation

![[그림 1] Prometheus Horizontal Sharding]({{site.baseurl}}/images/theory_analysis/Prometheus_Scaling_Federation/Prometheus_Scaling.PNG)

수집해야할 Metric이 증가하여 단일 Prometheus Server에서 모든 Metric 정보를 수집하기 힘든경우, 다수의 Prometheus Server를 띄우고 Metric을 분산하여 수집하는 **Horizontal Sharding** 기반의 Scaling 기법을 이용할 수 있다. [그림 1]은 Horizontal Sharding을 이용한 Scaling 기법을 나타내고 있다. Horizontal Sharding을 수행하여 다수의 Prometheus Server가 구동될 경우 일부 Prometheus Server는 다른 Prometheus Server가 저장하고 있는 Metric이 필요할 경우가 있다. 이러한 필요성을 충족시키기 위해서 Prometheus Server는 **Federation** 기능을 제공한다.

{% highlight yaml %}
scrape_configs:
  - job_name: 'federate'
    scrape_interval: 15s
    honor_labels: true
    metrics_path: '/federate'
    params:
      'match[]':
        - '{job="prometheus"}'
    static_configs:
      - targets:
        - 'prom-1:9090'
        - 'prom-2:9090'
{% endhighlight %}
<figure>
<figcaption class="caption">[파일 1] Federation Scrape Target 설정</figcaption>
</figure>

모든 Prometheus Server는 자신이 수집한 Metric을 외부에서 가져갈 수 있도록 /federate URL을 제공하고 있다. "/federate?[MatchQuery]" 처럼 Match Query를 /federate URL뒤에 붙여 가져올 Metric을 Filtering 한다. [파일 1]은 Federation 기능을 이용하여 외부의 prom-1, prom-2 Prometheus Server에서 Metric을 가져오도록 설정되어 있는 Promethues Server의 설정을 나타내고 있다. "[prom-1, prom-2]:9090/federate?match[]={job="prometheus"}" URL을 이용하여 job Label에 prometheus 문자열이 저장되어 있는 모든 metric 정보를 15초의 주기로 가져오도록 설정되어 있다.

![[그림 2] Prometheus Server의 Federation 구성]({{site.baseurl}}/images/theory_analysis/Prometheus_Scaling_Federation/Prometheus_Federation.PNG)

[그림 2]는 Prometheus Server의 Federation 구성을 나타내고 있다. Prometheus Server 사이의 계층을 두고 Tree 형태로 Federation을 구성하는 방법을 Hierarchical Federation이라고 명칭한다. 부모 Prometheus Server는 자식 Prometheus들의 통합 Metric 제공 및 통합 Metric을 기반으로하는 Alert을 제공하는 용도로 이용된다. 동일 Level의 Prometheus Server 사이의 Federation을 구성하는 방법은 Cross-service Federation이라고 명칭한다.

### 2. 참조

* [https://prometheus.io/docs/prometheus/latest/federation/](https://prometheus.io/docs/prometheus/latest/federation/)
* [https://www.robustperception.io/federation-what-is-it-good-for](https://www.robustperception.io/federation-what-is-it-good-for)
* [https://stackoverflow.com/questions/48751632/prometheus-federation-match-params-do-not-work](https://stackoverflow.com/questions/48751632/prometheus-federation-match-params-do-not-work)