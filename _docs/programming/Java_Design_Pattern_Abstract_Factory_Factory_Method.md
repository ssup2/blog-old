---
title: Java Design Pattern Abstract Factory, Factory Method
category: Programming
date: 2021-05-15T12:00:00Z
lastmod: 2021-05-15T12:00:00Z
comment: true
adsense: true
---

Java로 구현하는 Abstract Factory Pattern과 Factory Method를 분석한다. 

### 1. Java Abstract Factory Pattern

{% highlight java linenos %}
public abstract class Product {
    public abstract String getName();
}

public class Book extends Product {
    private String name;

    public Book (String name) {
        this.name = name;
    }

    @Override
    public String getName() {
        return this.name;
    }
}

public class Phone extends Product {
    private String name;

    public Phone (String name) {
        this.name = name;
    }

    @Override
    public String getName() {
        return this.name;
    }
}

public interface ProductAbstractFactory {
    public Product createProduct();
}

public class BookFactory implements ProductAbstractFactory {
    private String name;

    public BookFactory(String name) {
        this.name = name;
    }

    public Product createProduct() {
        return new Book(name, price);
    }
}

public class PhoneFactory implements ProductAbstractFactory {
    private String name;

    public PhoneFactory(String name) {
        this.name = name;
    }

    public Product createProduct() {
        return new Phone(name, price);
    }
}
{% endhighlight %}
<figure>
<figcaption class="caption">[Code 1] </figcaption>
</figure>

### 2. Java Factory Method Pattern

### 3. Abstrct Factory VS Factory Method

### 4. 참조

* [https://stackoverflow.com/questions/5739611/what-are-the-differences-between-abstract-factory-and-factory-design-patterns](https://stackoverflow.com/questions/5739611/what-are-the-differences-between-abstract-factory-and-factory-design-patterns)
* [https://blog.seotory.com/post/2016/08/java-abstract-factory-pattern](https://blog.seotory.com/post/2016/08/java-abstract-factory-pattern)
* [https://blog.seotory.com/post/2016/08/java-factory-pattern](https://blog.seotory.com/post/2016/08/java-factory-pattern)