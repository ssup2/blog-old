---
title: PromQL Vector Matching
category: Theory, Analysis
date: 2022-03-04T12:00:00Z
lastmod: 2022-03-04T12:00:00Z
comment: true
adsense: true
---

PromQL의 Vector Matching 문법을 분석한다.

### 1. PromQL Vector Matching

PromQL의 Vector Matching은 의미 그대로 두개의 Instant Vector Type의 Data를 연산(Matching)시키는 문법이다. PromQL에서 가장 많이 이용되는 문법중 하나이다. Instant Vector Type에 존재하는 하나의 값을 어떻게 연산시키는지에 따라서 One-to-one Matching, One-to-many/Many-to-one Matching, Many-to-many Matching이 존재한다. 여기서 Matching은 값에 존재하는 **Label**을 기준으로 이루어진다.

#### 1.1. One-to-one Vector Matching

One-to-one Vector Matching은 의미그대로 Instant Vector Type에 존재하는 하나의 값을 다른 Instant Vector Type에 존재하는 하나의 값과 1:1로 Matching시켜 연산하는 문법이다. Matching시 모든 Label이 Matching되어야 하는 경우와 일부 Label만 Matching되는 경우로 나눌 수 있다.

{% highlight text %}
--- query ---
candy1_count{}
--- result ---
candy1_count{color="blue", size="big"} 1
candy1_count{color="red", size="medium"} 3
candy1_count{color="green", size="small"} 5
{% endhighlight %}
<figure>
<figcaption class="caption">[Instant Vector 1] Candy 1 Count</figcaption>
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
<figcaption class="caption">[Instant Vector 2] Ice 1 Count</figcaption>
</figure>

[Instant Vector 1]과 [Instant Vector 2]는 One-to-one Vector Matching 설명을 위해서 이용되는 가상의 Instant Vector Type의 Data인 candy1_count, ice2_count를 나타내고 있다.

##### 1.1.1. 모든 Label Matching

{: .newline }
> **[Instant Vector] [Op] [Instant Vector]**
> ex) candy1_count{} + ice1_count{}
> ex) candy1_count{} * ice1_count{}
<figure>
<figcaption class="caption">[문법 1] One-to-one, 모든 Label Matching</figcaption>
</figure>

[문법 1]은 One-to-one Vector Matching에서 모든 Label을 Matching 시키는 경우의 문법과 예제를 타나내고 있다.

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

[Query 1]은 candy1_count와 ice2_count를 대상으로 One-to-one, 모든 Label을 Matching하는 경우를 나타내고 있다. candy1_count와 ice1_count의 Cardinality가 3이지만 결과의 Cardinality가 2인 이유는 모든 Label이 Matching하는 경우가 color="blue", size="big" / color="red", size="medium" 2가지 밖에 없기 때문이다. Operand는 "+"이기 때문에 두 값이 더해진다.

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