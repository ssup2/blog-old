---
title: LeetCode / Roman to Integer
category: Coding Test
date: 2022-02-05T12:00:00Z
lastmod: 2022-02-05T12:00:00Z
comment: true
adsense: true
---

### Problem


### Solution 1

{% highlight java linenos %}
class Solution {
    public int romanToInt(String s) {
        int result = 0;
        
        while (s.length() > 0) {
            if (s.startsWith("M")) {
                result += 1000;
                s = s.replaceFirst("^M", "");
            } else if (s.startsWith("CM")) {
                result += 900;
                s = s.replaceFirst("^CM", "");
            } else if (s.startsWith("D")) {
                result += 500;
                s = s.replaceFirst("^D", "");
            } else if (s.startsWith("CD")) {
                result += 400;
                s = s.replaceFirst("^CD", "");
            } else if (s.startsWith("C")) {
                result += 100;
                s = s.replaceFirst("^C", "");
            } else if (s.startsWith("XC")) {
                result += 90;
                s = s.replaceFirst("^XC", "");
            } else if (s.startsWith("L")) {
                result += 50;
                s = s.replaceFirst("^L", "");
            } else if (s.startsWith("XL")) {
                result += 40;
                s = s.replaceFirst("^XL", "");
            } else if (s.startsWith("X")) {
                result += 10;
                s = s.replaceFirst("^X", "");
            } else if (s.startsWith("IX")) {
                result += 9;
                s = s.replaceFirst("^IX", "");
            } else if (s.startsWith("V")) {
                result += 5;
                s = s.replaceFirst("^V", "");
            } else if (s.startsWith("IV")) {
                result += 4;
                s = s.replaceFirst("^IV", "");
            } else if (s.startsWith("I")) {
                result += 1;
                s = s.replaceFirst("^I", "");
            }
        }
        
        return result;
    }
}
{% endhighlight %}
<figure>
<figcaption class="caption">Solution 1</figcaption>
</figure>

* Description
  * M/1000, CM/900, D/500, CD/400, C/100, XC/90, L/50, XL/40, X/10, IX/9, V/5, IV/4, I/1 순서대로 문자열이 일치하는 검사
  * 문자열이 일치할 경우 일치한 문자열 제거 및 문자열과 일치하는 결과값 증가 시킴

* Time Complexity
  * O(len(s))
  * len(s)의 크기만큼 for Loop 수행

* Space Complexity
  * O(len(s))
  * 함수의 입력값으로 len(s)의 크기 만큼 Memory 이용

### Solution 2

{% highlight java linenos %}
class Solution {
    private class RomanInt {
        public String roman;
        public int integer;
        
        public RomanInt(String roman, int integer) {
            this.roman = roman;
            this.integer = integer;
        }
    }
    
    public int romanToInt(String s) {
        RomanInt[] romanIntArry = new RomanInt[13];
        romanIntArry[0] = new RomanInt("M", 1000);
        romanIntArry[1] = new RomanInt("CM", 900);
        romanIntArry[2] = new RomanInt("D", 500);
        romanIntArry[3] = new RomanInt("CD", 400);
        romanIntArry[4] = new RomanInt("C", 100);
        romanIntArry[5] = new RomanInt("XC", 90);
        romanIntArry[6] = new RomanInt("L", 50);
        romanIntArry[7] = new RomanInt("XL", 40);
        romanIntArry[8] = new RomanInt("X", 10);
        romanIntArry[9] = new RomanInt("IX", 9);
        romanIntArry[10] = new RomanInt("V", 5);
        romanIntArry[11] = new RomanInt("IV", 4);
        romanIntArry[12] = new RomanInt("I", 1);
        
        int result = 0;
        while (s.length() > 0) {
            for (int i = 0; i < romanIntArry.length; i++) {
                if (s.startsWith(romanIntArry[i].roman)) {
                    result += romanIntArry[i].integer;
                    s = s.replaceFirst("^"+romanIntArry[i].roman, "");
                    break;
                }
            }
        }
        
        return result;
    }
}
{% endhighlight %}
<figure>
<figcaption class="caption">Solution 2</figcaption>
</figure>

* Description
  * "Solution 1"과 동일한 방식이지만 Mapping Array를 이용