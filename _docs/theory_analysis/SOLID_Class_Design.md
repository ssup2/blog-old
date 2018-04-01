---
title: SOLID Design
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

    public void processHealthClaim (HealthInsuranceSurveyor surveyor)
    {
        if(surveyor.isValidClaim()){
            System.out.println("ClaimApprovalManager: Valid claim. Currently processing claim for approval....");
        }
    }

    public void processVehicleClaim (VehicleInsuranceSurveyor surveyor)
    {
        if(surveyor.isValidClaim()){
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

public class HealthInsuranceSurveyor extends InsuranceSurveyor{
    public boolean isValidClaim(){
        System.out.println("HealthInsuranceSurveyor: Validating health insurance claim...");
        return true;
    }
}

public class VehicleInsuranceSurveyor extends InsuranceSurveyor{
    public boolean isValidClaim(){
        System.out.println("VehicleInsuranceSurveyor: Validating vehicle insurance claim...");
        return true;
    }
}

public class ClaimApprovalManager {
    public void processClaim(InsuranceSurveyor surveyor){
        if(surveyor.isValidClaim()){
            System.out.println("ClaimApprovalManager: Valid claim. Currently processing claim for approval....");
        }
    }
}
{% endhighlight %}

ClaimApprovaManager는 InsuranceSurveyor Interface를 통해서 Code의 변화 없이 다양한 Surveyor Class를 수용 할 수 있게 되었다.

#### 1.3. Liskov Substitution

#### 1.4. Interface Segregation

#### 1.5. Dependency Invsersion

### 2. 참조

* [https://springframework.guru/solid-principles-object-oriented-programming/](https://springframework.guru/solid-principles-object-oriented-programming/)
