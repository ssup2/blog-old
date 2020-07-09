---
title: Redux
category: Theory, Analysis
date: 2020-07-06T12:00:00Z
lastmod: 2020-07-06T12:00:00Z
comment: true
adsense: true
---

JavaScript에서 State 정보를 저장하는 용도로 이용되는 Redux를 분석한다.

### 1. Redux

![[그림 1] Redux Architecture]({{site.baseurl}}/images/theory_analysis/Redux/Redux_Architecture.PNG){: width="650px"}

Redux는 JavaScript에서 State 정보를 저장하는 State 저장소 역활을 수행한다. Redux는 주로 React의 Component들의 State 정보를 저장하는 용도로 이용된다. [그림 1]은 Redux의 Architecture를 나타내고 있다. Store는 Redux에서 State 정보를 저장하는 State 저장소를 나타내며 Redux의 핵심 구성요소이다. Store는 State, Reducer, Middleware로 구성되어 있다.

{% highlight text %}
{
  counters: [
    {
      color: 'red',
      number: 4
    },
    {
      color: 'blue',
      number: 3
    },
    {
      color: 'black',
      number: 7
    }
  ]
}
{% endhighlight %}
<figure>
<figcaption class="caption">[Text 1] State Example</figcaption>
</figure>

State는 Store의 구성요소중 실제로 State 정보를 저장하는 공간을 의미한다. State는 JSON 형태와 같은 Key-value 기반의 Tree 형태로 State 정보를 저장한다. Redux에서는 Object Tree라고 표현한다. State는 오직 하나의 Object Tree만을 저장하고 관리한다. 즉 State는 하나의 **Global 상태 정보**만을 유지한다는 의미이다. [Text 1]은 State에 저장된 Counter Component들의 State 정보를 나타내고 있다. 3개의 Counter가 하나의 Tree아래 존재하고 있는 것과, 각 Counter의 색깔과 숫자 State 정보를 JSON 형태로 저장하고 있는걸 확인할 수 있다.

State에 저장된 State 정보는 반드시 Reducer라고 불리는 함수를 통해서만 변경 가능하다. Reducer는 State에 저장된 Current State 정보와 Action Creator으로 부터 생성된 Action을 Parameter로 받은 다음 Next State를 반환하는 함수이다. Reducer가 반환한 Next State는 State에 다시 저장된다. Next State 정보가 State에 저장될때는 **Serialize**되어 저장된다. Serialize로 인해서 성능적 불이익이 발생하지만 Race Condtion을 고려하지 않아도 되기 때문에 JavaScript App 개발과 Debugging을 쉽게 만들어준다.

{% highlight text %}
{ type: 'ADD_TODO', text: 'Go to swimming pool' }
{ type: 'TOGGLE_TODO', index: 1 }
{ type: 'SET_VISIBILITY_FILTER', filter: 'SHOW_ALL' }
{% endhighlight %}
<figure>
<figcaption class="caption">[Text 2] Action Example</figcaption>
</figure>

Action Creator가 생성하는 Action은 Event를 묘사하는 JavaScript의 Object를 의미한다. [Text 2]는 Action의 예제를 나타내고 있다. Action은 그 자체만으로 어떤 Event가 발생하였는지 명확하게 묘사되어야 한다. View는 사용자에게 노출되어 사용자의 입력을 Event로 Action Creator에게 전달한다. 또한 View는 자기 자신을 State의 Subscriber로 등록하여 State에 저장된 State 정보가 Reducer에 의해서 변경될 경우, 변경된 State 정보를 받아 사용자에게 노출하는 역활도 수행한다.

#### 1.1. React without Redux vs with Redux

![[그림 2] React Component Tree without Redux]({{site.baseurl}}/images/theory_analysis/Redux/React_Component_Tree_without_Redux.PNG){: width="350px"}

React Component들은 자신의 State를 저장하는 기능을 제공하고 있다. 따라서 Redux의 도움없이 React만으로도 State를 갖는 Component를 구성할 수 있다. [그림 2]는 Redux 없이 React만 이용하여 Component를 구성할 경우, Component Tree와 Component State의 변화를 나타내고 있다. React Component는 부모, 자식 관계를 갖을 수 있다. 예를 들어 [그림 2]에서 Component D가 Component F와 G를 이용하여 구성될 경우 Component D는 Component F와 G의 부모 Component가 된다. 반대로 Component D의 자식 Component는 Component F와 G가 된다.

React에서는 [그림 2]의 내용처럼 자식 Component가 부모 Component의 State를 직접 변경하는 방법을 권장하지 않는다. 대신 별도의 **Global Event System**을 이용하는 방법을 권장하고 있다. Component가 서로 직접 State를 변경할 경우 Component의 개수가 증가할 수록 복잡도도 증가하고 그에 따른 개발과 Debugging의 난이도도 증가할 수 밖에 없지만, Global Event System을 도입하면 이러한 문제를 해결할 수 있다. Redux는 State가 변경되면 변경된 State 내용을 Component (View)에게 전달하는 기능을 제공하고 있기 때문에 React의 Global Event System 역활을 수행할 수 있다.

![[그림 3] React Component Tree with Redux]({{site.baseurl}}/images/theory_analysis/Redux/React_Component_Tree_with_Redux.PNG){: width="350px"}

[그림 3]은 Redux와 함께 React를 이용하여 Component를 구성할 경우, Component Tree와 Component State의 변화를 나타내고 있다. Redux는 Global Event System의 역활을 수행한다. 자식 Component는 부모 Component 대신 Store에게 Action을 전송한다. Action을 받은 Store의 Reducer는 변경된 State를 Component에게 전달하여 Component의 State를 변경한다.

### 2. 참조

* [https://redux.js.org/introduction/getting-started](https://redux.js.org/introduction/getting-started)
* [https://velopert.com/3346](https://velopert.com/3346)
* [https://github.com/reduxjs/redux/issues/653](https://github.com/reduxjs/redux/issues/653)
* [http://codesheep.io/2017/01/06/redux-architecture/](http://codesheep.io/2017/01/06/redux-architecture/)
* [https://blog.logrocket.com/when-and-when-not-to-use-redux-41807f29a7fb/](https://blog.logrocket.com/)