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

AbstractStringBuilder Class의 Method를 살펴보면 Character Array를 **Memory Pool**로 이용하고 있으며, 문자열 조작시 Character Array의 내용을 직접 변경하는 것을 확인할 수 있다. 따라서 StringBuilder Instance를 이용하여 문자열을 조작할 경우 불필요한 Heap Memory 이용을 방지할 수 있다.

StringBuffer Class는 StringBuilder Class와 동일한 역활을 수행하지만 Method에 synchronized가 붙어 있어 다수 Thread 환경에서도 Thread-safe하게 이용할수 있다는 특징을 가지고 있다. 반면 단일 Thread 환경에서는 StringBuilder Class에 비해서 낮은 성능을 갖고 있다. 따라서 단일 Thread 환경에서는 StringBuilder Class를 이용하고 다수 Thread 환경에서는 StringBuilder Class를 이용하면 된다.

#### 1.2. String Literal

{% highlight java linenos %}
// main
public class main {
    public static void main(String[] args) {
        String strConstuctor1 = new String("ssup2");
        String strConstuctor2 = new String("ssup2");

        String strLiteral1 = "ssup2";
        String strLiteral2 = "ssup2";

        System.out.printf("%b", strConstuctor1.equals(strConstuctor2)); // true
        System.out.printf("%b", strLiteral1.equals(strLiteral2));       // true
        
        System.out.printf("%b", strConstuctor1 == strConstuctor2);      // false
        System.out.printf("%b", strLiteral1 == strLiteral2);            // true
    }
}
{% endhighlight %}
<figure>
<figcaption class="caption">[Code 4] String Literal</figcaption>
</figure>

String Instance를 초기화 하는 방법은 Constructor를 이용하는 방식과, String Literal을 이용하는 방식 2가지가 존재한다. [Code 4]의 4,5 Line은 Constructor를 이용하는 방식을 나타내고 있고, [Code 4]의 7,8 Line은 String Literal을 이용하는 방식을 나타내고 있다. 모든 String Instance가 "ssup2" 문자열을 가지고 있기 때문에 equal() Method를 통한 비교 수행시 문자열이 동일하다는 결과가 나오지만 "==" 연산자로 비교시 서로 다른 결과를 보이는것을 확인할 수 있다.

Constructor로 String Instance를 초기화를 수행하는 경우 String Instance는 Heap 영역에 새로 할당된다. 따라서 strConstuctor1의 주소와 strConstuctor2의 주소는 서로 다르다. 반면에 String Literal을 이용하여 초기화를 수행하는 경우에는 문자열이 동일하다면 동일한 String Literal을 공유한다. 따라서 strLiteral1의 주소와 strLiteral2의 주소는 동일하다.

String Literal은 **Constant String Pool**에 위치한다. Constant String Pool은 Java 6 Version 이하에서는 Heap의 "Permanent Generation" 영역에 위치하고 있고, Java 7 Version 이후에서는 Heap의 "Young/Old Generation"에 위치하여 Garbage Collection의 대상이 된다.

### 2. 참조

* [https://velog.io/@new_wisdom/Java-String-vs-StringBuffer-vs-StringBuilder](https://velog.io/@new_wisdom/Java-String-vs-StringBuffer-vs-StringBuilder)
* [https://velog.io/@ditt/Java-String-literal-vs-new-String](https://velog.io/@ditt/Java-String-literal-vs-new-String)
