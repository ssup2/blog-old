---
title: Java String
category: Programming
date: 2021-05-23T12:00:00Z
lastmod: 2021-05-23T12:00:00Z
comment: true
adsense: true
---

Java의 String을 분석한다.

### 1. Java String

{% highlight java linenos %}
public final class String
    implements java.io.Serializable, Comparable<String>, CharSequence
{
    private final char value[];
    private final int offset;
    private final int count;

    public String() {
        this.offset = 0;
        this.count = 0;
        this.value = new char[0];
    }

    public String(String original) {
        int size = original.count;
        char[] originalValue = original.value;
        char[] v;
        if (originalValue.length > size) {
            // The array representing the String is bigger than the new
            // String itself.  Perhaps this constructor is being called
            // in order to trim the baggage, so make a copy of the array.
            int off = original.offset;
            v = Arrays.copyOfRange(originalValue, off, off+size);
        } else {
            // The array representing the String is the same
            // size as the String, so no point in making a copy.
            v = originalValue;
        }
        this.offset = 0;
        this.count = size;
        this.value = v;
    }

    public String(char value[]) {
        int size = value.length;
        this.offset = 0;
        this.count = size;
        this.value = Arrays.copyOf(value, size);
    }
{% endhighlight %}
<figure>
<figcaption class="caption">[Code 1] String Class</figcaption>
</figure>

Java에서는 문자열 처리를 위한 String Class를 제공한다. [Code 1]은 Java의 String Class의 일부를 나타내고 있다. String Class의 Member 변수를 살펴보면 모두 **final**이 붙어 있는것을 확인할 수 있다. 즉 String Instance에 한번 저장된 문자열은 변경할 수 없다는 것을 의미한다. 따라서 String Class의 "+" 연산자를 이용하여 문자열을 결합하는 경우 새로운 String Instance가 생성된다. 이러한 특징 때문에 Java Code에서 "+" 연산자를 이용하여 문자열 결합을 많이 수행할 경우, String Instance가 Heap Memory 영역을 점령하여 Heap Memory 공간이 부족할 수 있다.

#### 1.1. StringBuilder, StringBuffer

{% highlight java linenos %}
public final class StringBuilder
    extends AbstractStringBuilder
    implements java.io.Serializable, CharSequence
{
    public StringBuilder() {
        super(16);
    }

    public StringBuilder(int capacity) {
        super(capacity);
    }

    public StringBuilder(String str) {
        super(str.length() + 16);
        append(str);
    }

    public StringBuilder(CharSequence seq) {
        this(seq.length() + 16);
        append(seq);
    }

    public StringBuilder append(Object obj) {
        return append(String.valueOf(obj));
    }

    public StringBuilder append(String str) {
        super.append(str);
        return this;
    }

    private StringBuilder append(StringBuilder sb) {
        if (sb == null)
            return append("null");
        int len = sb.length();
        int newcount = count + len;
        if (newcount > value.length)
            expandCapacity(newcount);
        sb.getChars(0, len, value, count);
        count = newcount;
        return this;
    }

    public StringBuilder append(StringBuffer sb) {
        super.append(sb);
        return this;
    }

    public StringBuilder append(CharSequence s) {
        if (s == null)
            s = "null";
        if (s instanceof String)
            return this.append((String)s);
        if (s instanceof StringBuffer)
            return this.append((StringBuffer)s);
        if (s instanceof StringBuilder)
            return this.append((StringBuilder)s);
        return this.append(s, 0, s.length());
    }

    public StringBuilder append(char[] str) {
        super.append(str);
        return this;
    }
{% endhighlight %}
<figure>
<figcaption class="caption">[Code 2] StringBuilder Class</figcaption>
</figure>


{% highlight java linenos %}
abstract class AbstractStringBuilder implements Appendable, CharSequence {
    char[] value;
    int count;

    AbstractStringBuilder() {
    }

    AbstractStringBuilder(int capacity) {
        value = new char[capacity];
    }

    public int length() {
        return count;
    }

    public int capacity() {
        return value.length;
    }

    public AbstractStringBuilder append(Object obj) {
        return append(String.valueOf(obj));
    }

    public AbstractStringBuilder append(String str) {
        if (str == null) str = "null";
        int len = str.length();
        ensureCapacityInternal(count + len);
        str.getChars(0, len, value, count);
        count += len;
        return this;
    }

    public AbstractStringBuilder append(StringBuffer sb) {
        if (sb == null)
            return append("null");
        int len = sb.length();
        ensureCapacityInternal(count + len);
        sb.getChars(0, len, value, count);
        count += len;
        return this;
    }

    public AbstractStringBuilder append(CharSequence s) {
        if (s == null)
            s = "null";
        if (s instanceof String)
            return this.append((String)s);
        if (s instanceof StringBuffer)
            return this.append((StringBuffer)s);
        return this.append(s, 0, s.length());
    }

    public AbstractStringBuilder append(char[] str) {
        int len = str.length;
        ensureCapacityInternal(count + len);
        System.arraycopy(str, 0, value, count, len);
        count += len;
        return this;
    }
{% endhighlight %}
<figure>
<figcaption class="caption">[Code 3] AbstractStringBuilder Class</figcaption>
</figure>

Java에서는 문자열 변경이 자주 발생하는 경우에는 String Class를 이용하는것 보다는 StringBuilder Class나 StringBuffer Class를 이용하는 것을 권장한다. [Code 2]는 StringBuilder class를 나타내고 있고, [Code 3]은 StringBuilder Class의 부모 Class인 AbstractStringBuilder Class를 나타내고 있다. AbstractStringBuilder Class의 Member Variable을 보면 final이 붙지 않은 Character Array가 존재하는 것을 확인할 수 있다.

AbstractStringBuilder Class의 Method를 살펴보면 Character Array를 Memory Pool로 이용하고 있으며, 문자열 조작시 Character Array의 내용을 직접 변경하는 것을 확인할 수 있다. 따라서 StringBuilder Instance를 이용하여 문자열을 조작할 경우 불필요한 Heap Memory 이용을 방지할 수 있다.

StringBuffer Class는 StringBuilder Class와 동일한 역활을 수행하지만 Method에 synchronized가 붙어 있어 다수 Thread 환경에서도 Thread-safe하게 이용할수 있다는 특징을 가지고 있다. 반면 단일 Thread 환경에서는 StringBuilder Class에 비해서 낮은 성능을 갖고 있다. 따라서 단일 Thread 환경에서는 StringBuilder Class를 이용하고 다수 Thread 환경에서는 StringBuilder Class를 이용하면 된다.

#### 1.2. String Compare

### 2. 참조

* [https://velog.io/@new_wisdom/Java-String-vs-StringBuffer-vs-StringBuilder](https://velog.io/@new_wisdom/Java-String-vs-StringBuffer-vs-StringBuilder)
