---
title: PromQL Vector Matching
category: Theory, Analysis
date: 2022-03-04T12:00:00Z
lastmod: 2022-03-04T12:00:00Z
comment: true
adsense: true
---

PromQL의 Join 문법을 분석한다.

### 1. PromQL Vector Matching

#### 1.1. One-to-one Vector Matching

{% highlight text %}
--- query ---
candy_count{}
--- result ---
candy_count{color="blue", size="big"} 10
candy_count{color="red", size="medium"} 10
candy_count{color="green", size="small"} 10
{% endhighlight %}
<figure>
<figcaption class="caption">[Instant Vector 1] Candy 1</figcaption>
</figure>

{% highlight text %}
--- query --- 
ice_count{}
--- result ---
ice_count{color="blue", size="big"} 20
ice_count{color="red", size="medium"} 20
ice_count{color="green", size="big"} 20
{% endhighlight %}
<figure>
<figcaption class="caption">[Instant Vector 2] Ice 1</figcaption>
</figure>

##### 1.1.1. 모든 Label Matching

{: .newline }
> **[Instanct Vector 1] [Op] [Instanct Vector 2]**
> ex) candy_count{} + ice_count{}
> ex) candy_count{} - ice_count{}
<figure>
<figcaption class="caption">[문법 1] One-to-one, 모든 Label Matching</figcaption>
</figure>

{% highlight cpp linenos %}
--- query --- 
candy_count{} + ice_count{}
--- result ---
{color="blue", size="big"} 30
{color="red", size="medium"} 30
{% endhighlight %}
<figure>
<figcaption class="caption">[Query 1] One-to-one, 모든 Label Matching</figcaption>
</figure>

##### 1.1.2 일부 Label Matching

{: .newline }
> **[Instanct Vector 1] [Op] on([label1], [label2] ...) [Instanct Vector 2]**
> ex) candy_count{} + on(color) ice_count{}
<figure>
<figcaption class="caption">[문법 2] One-to-one, 일부 Label Matching, on</figcaption>
</figure>

{% highlight cpp linenos %}
--- query --- 
candy_count{} + on(color) ice_count{}
--- result ---
{color="blue"} 30
{color="red"} 30
{color="green"} 30
{% endhighlight %}
<figure>
<figcaption class="caption">[Query 2] One-to-one, 일부 Label Matching, on</figcaption>
</figure>

{: .newline }
> **[Instanct Vector 1] [Op] ignoring([label1], [label2] ...) [Instanct Vector 2]**
> ex) candy_count{} + ignoring(size) ice_count{}
<figure>
<figcaption class="caption">[문법 3] One-to-one, 일부 Label Matching, ignoring</figcaption>
</figure>

{% highlight cpp linenos %}
--- query --- 
candy_count{} + ignoring(size) ice_count{}
--- result ---
{color="blue"} 30
{color="red"} 30
{color="green"} 30
{% endhighlight %}
<figure>
<figcaption class="caption">[Query 3] One-to-one, 일부 Label Matching, ignoring</figcaption>
</figure>

{% highlight cpp linenos %}
--- query --- 
candy_count{} + on(size) ice_count{}
--- result ---
Error
{% endhighlight %}
<figure>
<figcaption class="caption">[Query 4] One-to-one, 일부 Label Matching, Error</figcaption>
</figure>

#### 1.2. One-to-many Vector Matching

#### 1.3. Many-to-many Vector Matching

### 2. 참조

* [https://iximiuz.com/en/posts/prometheus-vector-matching/](https://iximiuz.com/en/posts/prometheus-vector-matching/)
* [https://devthomas.tistory.com/15](https://devthomas.tistory.com/15)
* [https://blog.naver.com/PostView.nhn?blogId=alice_k106&logNo=221535575875](https://blog.naver.com/PostView.nhn?blogId=alice_k106&logNo=221535575875)