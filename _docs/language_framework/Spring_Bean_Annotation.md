---
title: Spring Bean Annotation
category: Language, Framework
date: 2018-02-17T12:00:00Z
lastmod: 2018-02-17T12:00:00Z
comment: true
adsense: true
---

Spring의 Bean과 연관된 Annotation을 분석한다.

### 1. @Component

{% highlight JAVA linenos %}
@Component
public class MyComponentA {
}

@Component("myComponentC")
public class MyComponentB {
}
{% endhighlight %}

@Component가 붙은 Class의 Instance는 Spring에서 Bean으로 관리된다. Spring은 @Component가 붙은 Class를 Scan하여 Class 관련 정보를 얻는다. 그 후 Spring은 얻은 Class 관련 정보를 바탕으로 Bean을 생성하고 필요에 따라 DI(Dependency Injection)를 수행한다. Bean의 Default 이름은 Class 이름에서 첫글자를 소문자로 바꾼것을 이용한다. 따라서 위의 MyComponentA Class의 Bean 이름은 myComponentA가 된다. Bean의 이름은 @Component Annotation의 Value로 명시 할 수도 있다. 위의 MyComponentB Class의 Bean의 이름은 @Component Annotation에 명시된 myComponentC가 된다. 

### 2. @Configuration

#### 2.1. @ComponentScan

#### 2.2. @Bean

### 3. @Service

### 4. @Controller

### 5. @Repository

### 6. 참조

* [https://www.baeldung.com/spring-bean-annotations](https://www.baeldung.com/spring-bean-annotations)

