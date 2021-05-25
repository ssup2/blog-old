---
title: Java Design Pattern Command
category: Programming
date: 2021-05-25T12:00:00Z
lastmod: 2021-05-25T12:00:00Z
comment: true
adsense: true
---

Java로 구현하는 Command Pattern을 정리한다.

### 1. Java Command Pattern

Command Pattern은 요청(Command)을 캡슐화 하여 요청자가 요청에 대해서 정확히 파악하고 있지 않더라도 요청을 수행할수 있도록 만드는 Pattern이다. Command Pattern은 다음과 같은 역활을 수행하는 Class로 구성된다.

* Receiver : 요청을 전달 받아 실제 요청을 처리하는 역활을 수행하는 Class이다.
* Command : Recevier에게 **구체적인 요청**을 전달하는 역활을 수행하는 Class이다. Command Class는 Command Interface를 구현해야 하며, Receiver Instance를 내포하고 있다.
* Invoker : Concreate Instance의 집합 Class이다. 요청자는 Invoker를 통해서 Command 객체를 호출하여 Receiver에게 요청을 전달한다.

{% highlight java linenos %}
// receiver
public class Light{
     public Light(){}

     public void turnOn(){
        System.out.println("light on");
     }

     public void turnOff(){
        System.out.println("light off");
     }
}

// command interface
public interface Command{
    void execute();
}

// concrete command
public class TurnOnLightCommand implements Command{
   private Light theLight;

   public TurnOnLightCommand(Light light){
        this.theLight=light;
   }

   public void execute(){
      theLight.turnOn();
   }
}

public class TurnOffLightCommand implements Command{
   private Light theLight;

   public TurnOffLightCommand(Light light){
        this.theLight=light;
   }

   public void execute(){
      theLight.turnOff();
   }
}

// invoker
public class Switch {
    private Command flipUpCommand;
    private Command flipDownCommand;

    public Switch(Command flipUpCmd, Command flipDownCmd){
        this.flipUpCommand = flipUpCmd;
        this.flipDownCommand = flipDownCmd;
    }

    public void flipUp(){
         flipUpCommand.execute();
    }

    public void flipDown(){
         flipDownCommand.execute();
    }
}

// main
public class Main{
   public static void main(String[] args){
       Light light=new Light();
       Command switchUp=new TurnOnLightCommand(light);
       Command switchDown=new TurnOffLightCommand(light);

       Switch s= new Switch(switchUp, switchDown);
       s.flipUp();   // light on
       s.flipDown(); // light off
   }
}
{% endhighlight %}
<figure>
<figcaption class="caption">[Code 1] Java Command Pattern</figcaption>
</figure>

[Code 1]은 Java로 구현한 Command Pattern을 나타내고 있다. Light Class는 Recevier, TurnOnLightCommand/TurnOffLightCommand Class는 Command, Switch Class는 Invoker 역활을 수행한다. main() 함수에서 Switch Instance를 통해서 Light On/Off 동작을 수행하는 것을 확인 할 수 있다.

### 2. 참조

* [https://stackoverflow.com/questions/32597736/why-should-i-use-the-command-design-pattern-while-i-can-easily-call-required-met](https://stackoverflow.com/questions/32597736/why-should-i-use-the-command-design-pattern-while-i-can-easily-call-required-met)
* [https://www.tutorialspoint.com/design_pattern/command_pattern.htm](https://www.tutorialspoint.com/design_pattern/command_pattern.htm)
* [https://stackoverflow.com/questions/4834979/difference-between-strategy-pattern-and-command-pattern](https://stackoverflow.com/questions/4834979/difference-between-strategy-pattern-and-command-pattern)
* [https://ko.wikipedia.org/wiki/%EC%BB%A4%EB%A7%A8%EB%93%9C_%ED%8C%A8%ED%84%B4](https://ko.wikipedia.org/wiki/%EC%BB%A4%EB%A7%A8%EB%93%9C_%ED%8C%A8%ED%84%B4)
* [https://gdtbgl93.tistory.com/23](https://gdtbgl93.tistory.com/23)
* [https://blog.hexabrain.net/352](https://blog.hexabrain.net/352)