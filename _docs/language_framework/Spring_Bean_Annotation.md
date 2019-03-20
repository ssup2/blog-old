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

@Component가 붙은 Class의 Instance는 Spring에서 Bean으로 관리된다. Spring은 @Component가 붙은 Class를 Scan하여 Class 관련 정보를 얻는다. 그 후 Spring은 얻은 Class 관련 정보를 바탕으로 Bean을 생성하고 필요에 따라 DI(Dependency Injection)를 수행한다. Bean의 Default 이름은 Class 이름에서 첫글자를 소문자로 바꾼것을 이용한다. 따라서 위의 MyComponentA Class의 Bean 이름은 myComponentA가 된다. Bean의 이름은 @Component의 Value로 명시 할 수도 있다. 위의 MyComponentB Class의 Bean의 이름은 @Component의 Value에 명시된 myComponentC가 된다. 

### 2. @Configuration

{% highlight JAVA linenos %}
public class MyBean {
}

@Configuration
@ComponentScan("com.ssup2")
public class MyConfig {

    @Bean
    public Mybean myBean() {
        return new myBean();
    }
}
{% endhighlight %}

@Configuration은 Spring에게 Bean Method를 포함하고 있는 Class라는걸 알려주기 위한 Annotation이다. 또한 Spring의 Component Scanner에게 Component Class의 위치를 알려주어 Spring이 Component Class의 Instance가 Bean으로 관리 될 수 있도록 설정한다. 따라서 @configuration을 통해서 개발자가 Annotation 기반의 Configuration이 가능하도록 한다. 위의 Code에서 @Bean을 이용하여 myBean이라는 Bean Method를 정의하고 있다. 또한 @ComponentScan을 이용하여 Component Scanner에게 Component Class가 Package를 알려주고 있다. 

@Configuration은 @Component를 상속하고 있다. 따라서 @Configuration이 붙은 Class의 Instance 역시 Spring의 Bean으로 관리된다.

#### 2.1. @Bean

{% highlight JAVA linenos %}
public class MyBeanA {
}

public class MyBeanB {
}

@Configuration
public class MyConfig {

    @Bean
    public MybeanA myBeanA() {
        return new myBeanA();
    }

    @Bean("myBeanC")
    public MybeanB myBeanB() {
        return new myBeanB();
    }
}
{% endhighlight %}

@Bean은 Bean Method에 붙여 해당 Method가 Bean Method인 것을 Spring에게 알리는 역활을 수행한다. Bean Method는 반드시 Instance를 반환한다. Bean Method를 통해 생성되는 Bean의 Default 이름은 Method 이름이 된다. 따라서 위의 myBeanA() Method를 통해 생성되는 Bean의 이름은 myBeanA가 된다. 또한 @Bean의 Value를 통해서 Bean Method를 통해 생성되는 Bean의 이름을 지정할 수 있다. 위의 myBeanB() Method를 통해 생성되는 Bean의 이름은 @Bean의 Value인 myBeanC가 된다.

### 3. @Service, @Controller, @Repository

{% highlight JAVA linenos %}
@Service
public class MyService {
}

@Controller
public class MyController {
}

@Repository
public class MyRepository {
}
{% endhighlight %}

@Service는 Business Logic을 담고있는 Class에 붙인다. @Controller는 MVC Pattern의 Controller를 담당하는 Class에 붙인다. @Repository는 Data Access를 담당하는 Class에 붙인다. @Service, @Controller, @Repository 모두 @Component를 상속하고 있다. 따라서 앞의 3개의 Annotation이 붙은 Class의 Instance는 Spring의 Bean으로 관리된다.

### 4. 참조

* [https://www.baeldung.com/spring-bean-annotations](https://www.baeldung.com/spring-bean-annotations)
* [http://wonwoo.ml/index.php/post/2000](http://wonwoo.ml/index.php/post/2000)

