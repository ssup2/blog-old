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
  * Basic

### Solution

#### Solution 1

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

* Time Complexity 
  * O(len(str))

* Space Complexity 
  * O(len(str))
