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
candy1_count{}
--- result ---
candy1_count{color="blue", size="big"} 1
candy1_count{color="red", size="medium"} 3
candy1_count{color="green", size="small"} 5
{% endhighlight %}
<figure>
<figcaption class="caption">[Instant Vector 1] Candy 1</figcaption>
</figure>

{% highlight text %}
--- query --- 
ice1_count{}
--- result ---
ice1_count{color="blue", size="big"} 2
ice1_count{color="red", size="medium"} 4
ice1_count{color="green", size="big"} 6
{% endhighlight %}
<figure>
<figcaption class="caption">[Instant Vector 2] Ice 1</figcaption>
</figure>

##### 1.1.1. 모든 Label Matching

{: .newline }
> **[Instant Vector] [Op] [Instant Vector]**
> ex) candy1_count{} + ice1_count{}
> ex) candy1_count{} - ice1_count{}
<figure>
<figcaption class="caption">[문법 1] One-to-one, 모든 Label Matching</figcaption>
</figure>

{% highlight text %}
--- query --- 
candy1_count{} + ice1_count{}
--- result ---
{color="blue", size="big"} 3 (1+2)
{color="red", size="medium"} 7 (3+4)
{% endhighlight %}
<figure>
<figcaption class="caption">[Query 1] One-to-one, 모든 Label Matching</figcaption>
</figure>

##### 1.1.2 일부 Label Matching

{: .newline }
> **[Instant Vector] [Op] on([label], ...) [Instant Vector]**
> ex) candy1_count{} + on(color) ice1_count{}
<figure>
<figcaption class="caption">[문법 2] One-to-one, 일부 Label Matching, on</figcaption>
</figure>

{% highlight text %}
--- query --- 
candy1_count{} + on(color) ice1_count{}
--- result ---
{color="blue"} 3 (1+2)
{color="red"} 7 (3+4)
{color="green"} 11 (5+6)
{% endhighlight %}
<figure>
<figcaption class="caption">[Query 2] One-to-one, 일부 Label Matching, on</figcaption>
</figure>

{: .newline }
> **[Instant Vector] [Op] ignoring([label], ...) [Instant Vector]**
> ex) candy1_count{} + ignoring(size) ice1_count{}
<figure>
<figcaption class="caption">[문법 3] One-to-one, 일부 Label Matching, ignoring</figcaption>
</figure>

{% highlight text %}
--- query --- 
candy1_count{} + ignoring(size) ice1_count{}
--- result ---
{color="blue"} 3 (1+2)
{color="red"} 7 (3+4)
{color="green"} 11 (5+6)
{% endhighlight %}
<figure>
<figcaption class="caption">[Query 3] One-to-one, 일부 Label Matching, ignoring</figcaption>
</figure>

{% highlight text %}
--- query --- 
candy1_count{} + on(size) ice1_count{}
--- result ---
Error
{% endhighlight %}
<figure>
<figcaption class="caption">[Query 4] One-to-one, 일부 Label Matching, Error</figcaption>
</figure>

#### 1.2. One-to-many, Many-to-one Vector Matching

{% highlight text %}
--- query ---
candy2_count{}
--- result ---
candy2_count{color="blue", size="big"} 1
candy2_count{color="green", size="small"} 3
candy2_count{color="green", size="big"} 5
{% endhighlight %}
<figure>
<figcaption class="caption">[Instant Vector 3] Candy 2</figcaption>
</figure>

{% highlight text %}
--- query --- 
ice2_count{}
--- result ---
ice2_count{color="blue", size="big", flavor="soda"} 2
ice2_count{color="red", size="medium", flavor="cherry"} 4
ice2_count{color="green", size="big", flavor="lime"} 6
{% endhighlight %}
<figure>
<figcaption class="caption">[Instant Vector 4] Ice 2</figcaption>
</figure>

{: .newline }
> **[Instant Vector] [Op] on/ignoring([label], ...) group_left [Instant Vector]**
> **[Instant Vector] [Op] on/ignoring([label], ...) group_right [Instant Vector]**
> ex) candy2_count{} * on(size) group_left ice2_count{}
<figure>
<figcaption class="caption">[문법 4] One-to-many, Many-to-one Matching</figcaption>
</figure>

{% highlight text %}
--- query --- 
candy2_count{} * on(color) group_left ice2_count{}
--- result ---
{color="blue", size="big"} 2 (1*2)
{color="green", size="small"} 18 (3*6)
{color="green", size="big"} 30 (5*6)
{% endhighlight %}
<figure>
<figcaption class="caption">[Query 5] One-to-Many, group_left</figcaption>
</figure>

{: .newline }
> **[Instant Vector] [Op] on/ignoring([label], ...) group_left([label], ...) [Instant Vector]**
> **[Instant Vector] [Op] on/ignoring([label], ...) group_right([label], ...) [Instant Vector]**
> ex) candy2_count{} * on(size) group_left(flavor) ice2_count{}
<figure>
<figcaption class="caption">[문법 5] One-to-many, Many-to-one Matching, with Label</figcaption>
</figure>

{% highlight text %}
--- query --- 
candy2_count{} * on(color) group_left(flavor) ice2_count{}
--- result ---
{color="blue", size="big", flavor="soda"} 2 (1*2)
{color="green", size="small", flavor="lime"} 18 (3*6)
{color="green", size="big", flavor="lime"} 30 (5*6)
{% endhighlight %}
<figure>
<figcaption class="caption">[Query 6] One-to-Many, group_left, with Label</figcaption>
</figure>

#### 1.3. Many-to-many Vector Matching

### 2. 참조

* [https://iximiuz.com/en/posts/prometheus-vector-matching/](https://iximiuz.com/en/posts/prometheus-vector-matching/)
* [https://devthomas.tistory.com/15](https://devthomas.tistory.com/15)
* [https://blog.naver.com/PostView.nhn?blogId=alice_k106&logNo=221535575875](https://blog.naver.com/PostView.nhn?blogId=alice_k106&logNo=221535575875)