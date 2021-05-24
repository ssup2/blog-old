---
title: Java Design Pattern Factory
category: Programming
date: 2021-05-15T12:00:00Z
lastmod: 2021-05-15T12:00:00Z
comment: true
adsense: true
---

Java로 구현하는 Factory Pattern을 분석한다.

### 1. Java Factory Pattern

**Factory Pattern은 객체 생성 과정을 외부에 노출시키지 않고 싶을때 이용되는 Pattern이다.** Factory Pattern은 Simple Factory Pattern, Factory Method Pattern, Abstract Factory Pattern 3가지 Pattern이 존재한다.

{% highlight java linenos %}
// product
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
{% endhighlight %}
<figure>
<figcaption class="caption">[Code 1] Product Class</figcaption>
</figure>

[Code 1]은 Factory Pattern 소개를 위해서 예시로 이용하는 Product Class를 나타내고 있다. Product Class는 Abstract Class 역활을 수행하며, Book, Phone Class는 Product Class를 상속하여 구현한다.

#### 1.1. Simple Factory Pattern

{% highlight java linenos %}
// product
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

// factory
public class SimpleProductFactory {
    public static Product getProduct(String type, String name) {
        if ("book".equals(type))
            return new Book(name);
        else if ("phone".equals(type))
            return new Phone(name);
        return null;
    }
}

// main
public class main {
    public static void main(String[] args) {
        Product book = SimpleProductFactory.getProduct("book", "ssup2-book");
        Product phone = SimpleProductFactory.getProduct("phone", "ssup2-phone");
    }
}
{% endhighlight %}
<figure>
<figcaption class="caption">[Code 2] Simple Factory Pattern</figcaption>
</figure>

Simple Factory Pattern은 의미 그대로 간단하게 구현 가능한 Factory Pattern을 의미한다. [Code 2]는 SimpleProductFactory Class를 통해서 Simple Factory Pattern의 예제를 나타내고 있다. SimpleProductFactory의 getProduct() Method는 type에 따라서 다른 Product 객체를 생성하는 것을 확인할 수 있다. 간단한 구현이 가장 큰 장점이지만, Product의 종류가 추가될때 마다 SimpleProductFactory Class의 Code도 변경되어야 한다는 단점을 갖고 있다. 

#### 1.2. Factory Method Pattern

{% highlight java linenos %}
// factory
public abstract class ProductFactory {
    abstract protected Product getProduct(String name);
}

public class BookFactory extends ProductFactory {
    @Override
    abstract protected Product getProduct(String name) {
        return new Book(name);
    }
}

public class PhoneFactory extends ProductFactory {
    @Override
    abstract protected Product getProduct(String name) {
        return new Phone(name);
    }
}

// main
public class main {
    public static void main(String[] args) {
        bookFactory = new BookFactory();
        phoneFactory = new PhoneFactory();

        Product book = bookFactory.getProduct("ssup2-book");
        Product phone = phoneFactory.getProduct("ssup2-phone");
    }
}
{% endhighlight %}
<figure>
<figcaption class="caption">[Code 3] Factory Method Pattern</figcaption>
</figure>

Factory Method Pattern은 Simple Factory의 단점을 보완하는 Pattern이다. Factory Class를 상속하여 단일 Type의 객체를 생성하는 전용 Factory를 만드는 Pattern이다. [Code 3]은 Factory Method Pattern을 나타내고 있다. ProductFactory Class를 상속하여 Book 객체만을 생성하는 BookFactory Factory Class와 Phone 객체만을 생성하는 PhoneFactory Factory Class를 확인할 수 있다. Product의 종류가 추가되더라도 기존의 Factory 관련 Code를 수정할 필요가 없다는 장점을 갖고 있다.

#### 1.3. Abstract Factory Pattern

{% highlight java linenos %}
// factory
public abstract class ProductFactory {
    abstract protected Product getProduct(String name);
}

public class BookFactory extends ProductFactory {
    @Override
    abstract protected Product getProduct(String name) {
        return new Book(name);
    }
}

public class PhoneFactory extends ProductFactory {
    @Override
    abstract protected Product getProduct(String name) {
        return new Phone(name);
    }
}

public class AbstractProductFactory {
    private ProductFactory productFactory

    public ProductFactory(ProductFactory productFactory) {
        this.productFactory = productFactory;
    }

    public Product getProduct(String name) {
        return this.productFactory.getProduct(String name);
    }
}

// main
public class Main {
    public static void main(String[] args) {
        bookFactory = new AbstractProductFactory(new BookFactory());
        phoneFactory = new AbstractProductFactory(new PhoneFactory());

        Product book = bookFactory.getProduct("ssup2-book");
        Product phone = phoneFactory.getProduct("ssup2-phone");
    }
}
{% endhighlight %}
<figure>
<figcaption class="caption">[Code 4] Abstract Factory Pattern</figcaption>
</figure>

Abstract Factory Pattern은 주입되는 Factory 객체에 따라서 다양한 Type의 객체를 생성할 수 있는 Pattern이다. [Code 4]는 Abstract Factory Pattern를 나타내고 있다. AbstractProductFactory Class에 주입하는 Factory Class에 따라서 다양한 Type의 Product를 생성할 수 있는것을 확인할 수 있다.

### 2. 참조

* [https://medium.com/bitmountn/factory-vs-factory-method-vs-abstract-factory-c3adaeb5ac9a](https://medium.com/bitmountn/factory-vs-factory-method-vs-abstract-factory-c3adaeb5ac9a)
* [https://www.codeproject.com/Articles/716413/Factory-Method-Pattern-vs-Abstract-Factory-Pattern](https://www.codeproject.com/Articles/716413/Factory-Method-Pattern-vs-Abstract-Factory-Pattern)
* [https://stackoverflow.com/questions/5739611/what-are-the-differences-between-abstract-factory-and-factory-design-patterns](https://stackoverflow.com/questions/5739611/what-are-the-differences-between-abstract-factory-and-factory-design-patterns)
* [https://blog.seotory.com/post/2016/08/java-abstract-factory-pattern](https://blog.seotory.com/post/2016/08/java-abstract-factory-pattern)
* [https://blog.seotory.com/post/2016/08/java-factory-pattern](https://blog.seotory.com/post/2016/08/java-factory-pattern)