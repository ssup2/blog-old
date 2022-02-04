---
title: LeetCode / To Lower Case
category: Coding Test
date: 2022-01-20T12:00:00Z
lastmod: 2022-01-20T12:00:00Z
comment: true
adsense: true
---

### Problem

* Link
  * [https://leetcode.com/problems/to-lower-case/](https://leetcode.com/problems/to-lower-case/)

* Description
  * 문자열의 소문자를 대문자로 변경

* Type
  * X

### Solution 1

{% highlight java linenos %}
class Solution {
    public String toLowerCase(String str) {
        char[] charArry = str.toCharArray();
        for (int i = 0; i < charArry.length; i++) {
            charArry[i] = getLower(charArry[i]);
        }
        return new String(charArry);
    }
    
    private boolean isUpper(char c) {
        return (c >= 'A') && (c <= 'Z');
    }
    
    private char getLower(char c) {
        if (isUpper(c)) {
            return (char)((c - 'A') + 'a');
        } else {
            return c;
        }
    }
}
{% endhighlight %}
<figure>
<figcaption class="caption">Solution 1</figcaption>
</figure>

* Description
  * 문자열의 앞부터 하나씩 소문자인지 확인 후, 소문자인 경우 대문자로 변경

* Time Complexity 
  * O(len(str))
  * len(str) 크기만큼 for Loop 수행

* Space Complexity 
  * O(len(str))
  * 함수의 입력값으로 len(str) 크기 만큼 Memory 이용
