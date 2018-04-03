---
title: SOLID Class Design
category: Theory, Analysis
date: 2017-04-01T12:00:00Z
lastmod: 2017-04-01T12:00:00Z
comment: true
adsense: true
---

Class 설계시 5가지의 원칙을 제시해주는 SOLID를 정리한다.

### 1. SOLID

SOLID는 객체지향 프로그래밍에서 Class 설계시 5가지의 원칙을 제시해주는 용어를 의미한다. Single Responsibility, Open/closed, Liskov Substitution, Interface Segregation, Dependency Invsersion의 약자를 따서 SOLID라는 이름의 용어가 되었다.

#### 1.1. Single Responsibility

하나의 Class는 하나의 책임(Responsibility)를 갖는다. 즉 Class가 변경될 이유는 오직 한가지어야 한다는 의미이다.

{% highlight Java %}
class Text {
    String text;

    String getText() { ... }
    void setText(String s) { ... }

    /*methods that change the text*/
    void allLettersToUpperCase() { ... }
    void findSubTextAndDelete(String s) { ... }

    /*method for formatting output*/
    void printText() { ... }
}
{% endhighlight %}

Text Class는 Text를 변경하는 책임과 Text를 출력하는 책임 2가지의 책임을 갖고 있다.

{% highlight Java %}
class Text {
    String text;

    String getText() { ... }
    void setText(String s) { ... }

    /*methods that change the text*/
    void allLettersToUpperCase() { ... }
    void findSubTextAndDelete(String s) { ... }
}

class Printer {
    Text text;

    Printer(Text t) {
       this.text = t;
    }

    void printText() { ... }
}
{% endhighlight %}

Printer Class를 정의하고 Text Class가 갖고 있던 출력 책임을 Printer Class에게 위임하는 식으로 설계하여 Text Class와 Printer Class가 각각 하나의 책임만을 갖도록 변경할 수 있다.

#### 1.2. Open/closed

기능 확장에는 열려 있으면서, 기존 Class의 변경은 닫혀 있어야 한다는 원칙이다. 즉 Class의 변경을 최소화 화면서 새로운 기능 추가는 자유롭게 가능해야 한다는 의미이다.

{% highlight Java %}
public class ClaimApprovaManager {

    public void processHealthClaim (HealthInsuranceSurveyor surveyor) {
        if(surveyor.isValidClaim()) {
            System.out.println("ClaimApprovalManager: Valid claim. Currently processing claim for approval....");
        }
    }

    public void processVehicleClaim (VehicleInsuranceSurveyor surveyor) {
        if(surveyor.isValidClaim()) {
            System.out.println("ClaimApprovalManager: Valid claim. Currently processing claim for approval....");
        }
    }
}
{% endhighlight %}

ClaimApprovalManager Class는 Surveyor Class가 추가 될때마다 해당 Surveyor Class를 위한 ClaimApprovaManager의 Method가 추가되어야 하는 단점을 가지고 있다.

{% highlight Java %}
public abstract class InsuranceSurveyor {
    public abstract boolean isValidClaim();
}

public class HealthInsuranceSurveyor extends InsuranceSurveyor {
    public boolean isValidClaim() {
        System.out.println("HealthInsuranceSurveyor: Validating health insurance claim...");
        return true;
    }
}

public class VehicleInsuranceSurveyor extends InsuranceSurveyor {
    public boolean isValidClaim() {
        System.out.println("VehicleInsuranceSurveyor: Validating vehicle insurance claim...");
        return true;
    }
}

public class ClaimApprovalManager {
    public void processClaim(InsuranceSurveyor surveyor) {
        if(surveyor.isValidClaim()) {
            System.out.println("ClaimApprovalManager: Valid claim. Currently processing claim for approval....");
        }
    }
}
{% endhighlight %}

ClaimApprovaManager는 InsuranceSurveyor Interface를 통해서 Code의 변화 없이 다양한 Surveyor Class를 수용 할 수 있게 되었다.

#### 1.3. Liskov Substitution

Subclass는 언제나 자신의 Superclass를 대신할 수 있어야 한다는 원칙이다. 즉 Superclass의 Method 기능을 Subclass에서 임의로 변경하거나 오류가 발생하도록 수정하면 안된다는 의미이다.

{% highlight Java %}
public class Rectangle {
    protected double itsWidth;
    protected double itsHeight;

    public void SetWidth(double w) {
        this.itsWidth = w;
    }

    public void SetHeight(double h) {
        this.itsHeight = h;
    }
}

public class Square : Rectangle {
    public new void SetWidth(double w) {
        base.itsWidth = w;
        base.itsHeight = w;
    }

    public new void SetHeight(double h) {
        base.itsWidth = h;
        base.itsHeight = h;
    }
}
{% endhighlight %}

정사각형도 사각형이기 때문에 Square Class는 Rectangle Class를 상속해서 구현하였다. Rectangle Class에서는 Width와 Height를 각각 설정 할 수 있었지만, Sqaure Class에서는 Width와 Height가 동시에 같은 값으로 설정된다. 따라서 Liskov Substitution 원칙에 위반된 Class 설계이다.

#### 1.4. Interface Segregation

Interface를 이용하여 Class 구성시, Interface는 Class 구성에 불필요한 Method까지 정의하게 만들면 안된다는 원칙이다. 즉 Interface를 기능단위로 작게 쪼개고 Class에서 필요한 Interface를 선택해 구현하라는 의미이다.

{% highlight Java %}
public interface Toy {
    void setPrice(double price);
    void setColor(String color);
    void move();
    void fly();
}
{% endhighlight %}

위의 Toy Interface는 색깔, 이동, 비행 3가지 종류의 method를 정의하고 있다. 문제는 모든 장난감이 이동, 비행 기능을 갖고 있지 않기 때문에 이동, 비행 기능이 없는 Toy Class의 move, fly Method는 dummy Method가 된다는 점이 문제이다.

{% highlight Java %}
public interface Toy {
    void setPrice(double price);
    void setColor(String color);
}

public interface Movable {
    void move();
}

public interface Flyable {
    void fly();
}
{% endhighlight %}

Toy Interface를 분리하여 Movable, Flyable Interface를 만들었다. Toy Class 구성시 해당 Toy에 필요한 Interface만 선택하여 구성하면 된다.

#### 1.5. Dependency Invsersion

Class간의 의존은 Interface를 통한 느슨한 관계를 유지해야 한다는 원칙이다. Instance A가 Interface B를 통해 Instance B를 참조하는 경우, Instance A는 Instance B가 정확히 어떤 동작을 수행하는지는 알지 못한채 Instance B에 의존하게 된다. 이처럼 호출당하는 Instance가 호출하는 Instance의 동작을 결정하기 때문에 Dependency Invsersion이라는 용어가 쓰인다.

{% highlight Java %}
public class LightBulb {
    public void turnOn() {
        System.out.println("LightBulb: Bulb turned on...");
    }
    public void turnOff() {
        System.out.println("LightBulb: Bulb turned off...");
    }
}

public class ElectricSwitch {
    public LightBulb lightBulb;
    public boolean on;
    public ElectricSwitch(LightBulb lightBulb) {
        this.lightBulb = lightBulb;
        this.on = false;
    }
    public boolean isOn() {
        return this.on;
    }
    public void press(){
        boolean checkOn = isOn();
        if (checkOn) {
            lightBulb.turnOff();
            this.on = false;
        } else {
            lightBulb.turnOn();
            this.on = true;
        }
    }
}
{% endhighlight %}

ElectricSwitch Class는 LightBulb Class를 직접 참조하여 이용하고 있다. 새로운 전자제품이 추가 될때마다 ElectricSwith Class도 계속 변경되야 한다.

{% highlight Java %}
public interface Switchable {
    void turnOn();
    void turnOff();
}

public class ElectricSwitch implements Switch {
    public Switchable client;
    public boolean on;
    public ElectricSwitch(Switchable client) {
        this.client = client;
        this.on = false;
    }
    public boolean isOn() {
        return this.on;
    }
    public void press(){
        boolean checkOn = isOn();
        if (checkOn) {
            client.turnOff();
            this.on = false;
        } else {
            client.turnOn();
            this.on = true;
        }
    }
}

public class LightBulb implements Switchable {
    @Override
    public void turnOn() {
        System.out.println("LightBulb: Bulb turned on...");
    }

    @Override
    public void turnOff() {
        System.out.println("LightBulb: Bulb turned off...");
    }
}

public class Fan implements Switchable {
    @Override
    public void turnOn() {
        System.out.println("Fan: Fan turned on...");
    }

    @Override
    public void turnOff() {
        System.out.println("Fan: Fan turned off...");
    }
}
{% endhighlight %}

ElectricSwitch Class는 Switchable Class에만 의존한다. 그리고 Switchable Class의 동작은 Switchable Class에 LightBulb가 Injection 되었는지 아니면 FAN이 Injection 되었는지에 따라 달라진다.

### 2. 참조

* [https://springframework.guru/solid-principles-object-oriented-programming/](https://springframework.guru/solid-principles-object-oriented-programming/)
