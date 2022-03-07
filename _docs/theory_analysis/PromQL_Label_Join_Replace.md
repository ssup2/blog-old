---
title: PromQL Label Join, Replace
category: Theory, Analysis
date: 2022-03-07T12:00:00Z
lastmod: 2022-03-07T12:00:00Z
comment: true
adsense: true
---

PromQL의 Label Join가 Label Replace 문법을 정리한다.

### 1. PromQL Label Join

{: .newline }
> **label_join([Instant Vector], [Dest Label], [Seperator], [Src Label], [Src Label], ...)**
> ex) label_join(node_memory_MemAvailable_bytes, "dest_label", "+", "job", "endpoint", "namespace")
<figure>
<figcaption class="caption">[문법 1] PromQL Label Join</figcaption>
</figure>

Label Join은 기존의 Label들의 값을 조합하여 새로운 Label을 생성하는 문법이다. [문법 1]은 Label Join의 문법을 나타내고 있다. "Src Label"은 값을 가져오려는 Label을 나타내며 다수의 "Src Label"이 선택될 수 있다. "Seperator"는 가져온 Label 사이에 삽입되는 분리자를 의미한다. Empty String ("")으로도 설정할 수 있다. "Dest Label"은 "Src Label"과 "Seperator"로 구성된 값의 저장될 새로운 Label을 나타낸다.

{% highlight text %}
--- query ---
node_memory_MemAvailable_bytes{}
--- result ---
node_memory_MemAvailable_bytes{container="node-exporter", endpoint="metrics", instance="192.168.0.31:9100", job="node-exporter", namespace="monitoring", pod="prometheus-prometheus-node-exporter-lpqff", service="prometheus-prometheus-node-exporter"} 14897680384
node_memory_MemAvailable_bytes{container="node-exporter", endpoint="metrics", instance="192.168.0.32:9100", job="node-exporter", namespace="monitoring", pod="prometheus-prometheus-node-exporter-59wm5", service="prometheus-prometheus-node-exporter"} 6833418240
node_memory_MemAvailable_bytes{container="node-exporter", endpoint="metrics", instance="192.168.0.33:9100", job="node-exporter", namespace="monitoring", pod="prometheus-prometheus-node-exporter-9lzmv", service="prometheus-prometheus-node-exporter"} 9297317888
{% endhighlight %}
<figure>
<figcaption class="caption">[Query 1] node_memory_MemAvailable_bytes</figcaption>
</figure>

[Query 1]은 Label Join 예제를 위한 node_memory_MemAvailable_bytes Instant Vector Type의 Data를 보여주고 있다.

{% highlight text %}
--- query ---
label_join(node_memory_MemAvailable_bytes, "dest_label", "+", "job", "endpoint", "namespace")
--- result ---
node_memory_MemAvailable_bytes{container="node-exporter", dest_label="node-exporter+metrics+monitoring", endpoint="metrics", instance="192.168.0.31:9100", job="node-exporter", namespace="monitoring", pod="prometheus-prometheus-node-exporter-lpqff", service="prometheus-prometheus-node-exporter"} 14864846848
node_memory_MemAvailable_bytes{container="node-exporter", dest_label="node-exporter+metrics+monitoring", endpoint="metrics", instance="192.168.0.32:9100", job="node-exporter", namespace="monitoring", pod="prometheus-prometheus-node-exporter-59wm5", service="prometheus-prometheus-node-exporter"} 6715412480
node_memory_MemAvailable_bytes{container="node-exporter", dest_label="node-exporter+metrics+monitoring", endpoint="metrics", instance="192.168.0.33:9100", job="node-exporter", namespace="monitoring", pod="prometheus-prometheus-node-exporter-9lzmv", service="prometheus-prometheus-node-exporter"} 9297317888
{% endhighlight %}
<figure>
<figcaption class="caption">[Query 2] node_memory_MemAvailable_bytes with Join</figcaption>
</figure>

[Query 2]는 node_memory_MemAvailable_bytes를 이용한 Label Join의 예제를 나타내고 있다. "dest_label"이 추가된 것을 확인할 수 있고, "dest_label"의 값은 "job", "endpoint", "namespace" Label 값과 Seperator인 "+"으로 구성되어 있는것을 확인 할 수 있다.

### 2. PromQL Label Replace

{: .newline }
> **label_join([Instant Vector], [Dest Label], [Replacement], [Src Label], [Regex])**
> ex) label_replace(node_memory_MemAvailable_bytes, "dest_label", "$1", "job", "(.*)")
<figure>
<figcaption class="caption">[문법 2] PromQL Label Replace</figcaption>
</figure>

{% highlight text %}
--- query ---
label_replace(node_memory_MemAvailable_bytes, "dest_label", "$1", "job", "(.*)")
--- result ---
node_memory_MemAvailable_bytes{container="node-exporter", dest_label="node-exporter", endpoint="metrics", instance="192.168.0.31:9100", job="node-exporter", namespace="monitoring", pod="prometheus-prometheus-node-exporter-lpqff", service="prometheus-prometheus-node-exporter"} 14864846848
node_memory_MemAvailable_bytes{container="node-exporter", dest_label="node-exporter", endpoint="metrics", instance="192.168.0.32:9100", job="node-exporter", namespace="monitoring", pod="prometheus-prometheus-node-exporter-59wm5", service="prometheus-prometheus-node-exporter"} 6715412480
node_memory_MemAvailable_bytes{container="node-exporter", dest_label="node-exporter", endpoint="metrics", instance="192.168.0.33:9100", job="node-exporter", namespace="monitoring", pod="prometheus-prometheus-node-exporter-9lzmv", service="prometheus-prometheus-node-exporter"} 9297317888
{% endhighlight %}
<figure>
<figcaption class="caption">[Query 3] node_memory_MemAvailable_bytes with Replace</figcaption>
</figure>

### 3. 참조

* [https://prometheus.io/docs/prometheus/latest/querying/functions/#label_join](https://prometheus.io/docs/prometheus/latest/querying/functions/#label_join)
* [https://t3guild.com/2020/07/29/prometheus-promql/](https://t3guild.com/2020/07/29/prometheus-promql/)
* [https://devthomas.tistory.com/15](https://devthomas.tistory.com/15)
