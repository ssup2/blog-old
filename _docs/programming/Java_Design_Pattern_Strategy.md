---
title: Java Design Pattern Strategy
category: Programming
date: 2021-05-25T12:00:00Z
lastmod: 2021-05-25T12:00:00Z
comment: true
adsense: true
---

Java로 구현하는 Strategy Pattern을 정리한다.

### 1. Java Strategy Pattern

**Strategy Pattern은 서로 다른 알고리즘(Strategy)을 별도의 Class로 정의하고, 정의한 Class를 서로 교환해서 사용할 수 있도록 만든는 Pattern을 의미한다.** 다양한 알고리즘을 유연하게 변경하면서 이용하고 싶을때 Strategy Pattern이 이용된다.

{% highlight java linenos %}
// operation
public interface Operation {
   public int doOperation(int n1, int n2);
}

public class OperationAdd implements Operation {
   @Override
   public int doOperation(int n1, int n2) {
      return n1 + n2;
   }
}

public class OperationSub implements Operation{
   @Override
   public int doOperation(int n1, int n2) {
      return n1 - n2;
   }
}

// operator
public class Operator {
   private Operation operation;

   public Operator(Operation operation){
      this.operation = operation;
   }

   public int execute(int n1, int n2){
      return operation.doOperation(n1, n2);
   }
}

// main
public class Main {
    public static void main(String[] args) {
        Operator operatorAdd = new Operator(new OperationAdd());
        Operator operatorSub = new Operator(new OperationSub());

        operatorAdd.execute(10, 5); // 15
        operatorAdd.execute(10, 5); // 5
    }
}
{% endhighlight %}
<figure>
<figcaption class="caption">[Code 1] Java Strategy Pattern</figcaption>
</figure>

[Code 1]은 Java로 구현한 간단한 Strategy Pattern을 나타내고 있다. OperationAdd, OperationSub Class는 Operation Interface를 구현하는 구상 Class이며, 서로 다른 알고리즘(Strategy)을 갖고 있는 Class이다. Operator Class는 알고리즘을 가지고 있는 Operation Class를 Parameter로 받아서 이용하고 있는것을 확인할 수 있다.

### 2. 참조

* [https://www.tutorialspoint.com/design_pattern/strategy_pattern.htm](https://www.tutorialspoint.com/design_pattern/strategy_pattern.htm)