---
title: PromQL Label Join, Replace
category: Theory, Analysis
date: 2022-03-07T12:00:00Z
lastmod: 2022-03-07T12:00:00Z
comment: true
adsense: true
---

PromQL의 Label Replace 문법을 정리한다.

### 1. PromQL Label Join

{: .newline }
> **label_join([Instant Vector], [Dest Label], [Seperator], [Src Label], [Src Label], ...)**
> ex) label_join(node_memory_MemAvailable_bytes, "dest_label", "+", "job", "endpoint", "namespace")
<figure>
<figcaption class="caption">[문법 1] PromQL Label Join</figcaption>
</figure>

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
