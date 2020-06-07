---
title: macOS Keyborad, Mouse Key 설정
category: Record
date: 2020-06-07T12:00:00Z
lastmod: 2020-06-07T12:00:00Z
comment: true
adsense: true
---

### 1. 설치 환경

설정 환경을 다음과 같다.
* macOS 10.14.6 Mojave
* Dell KM717 Keyborad, Mouse

### 2. Karabiner-Elements 설치

Key 변경을 위해서 Karabiner-Elements을 설치한다.
* https://karabiner-elements.pqrs.org/

### 3. Karabiner-Elements의 Complex Modification Rules 파일 생성

{% highlight json %}
{
  "title": "Change language with right command and lang1",
  "rules": [
    {
      "description": "Change language with right command and lang1",
      "manipulators": [
        {
          "type": "basic",
          "from": {
            "key_code": "right_command"
          },
          "to": [
            {
              "key_code": "caps_lock"
            }
          ]
        },
        {
          "type": "basic",
          "from": {
            "key_code": "lang1"
          },
          "to": [
            {
              "key_code": "caps_lock"
            }
          ]
        }
      ]
    }
  ]
}
{% endhighlight %}
<figure>
<figcaption class="caption">[파일 1] ~/.config/karabiner/assets/complex_modifications/lang.json</figcaption>
</figure>

[파일 1]을 생성한다. [파일 1]은 Mac Keyboard의 오른쪽 Command Key와 Windows Keyboard의 한영 Key를 한글 영어 전환키로 설정한다.

{% highlight json %}
{
  "title": "Switch space with mouse buttons 3,4",
  "rules": [
    {
      "description": "Maps button 3 to right space switch, 4 to left space switch",
      "manipulators": [
        {
          "type": "basic",
          "from": {
            "pointing_button": "button4"
          },
          "to": [
            {
              "key_code": "left_arrow",
              "modifiers": "left_control"
            }
          ]
        },
        {
          "type": "basic",
          "from": {
            "pointing_button": "button3"
          },
          "to": [
            {
              "key_code": "right_arrow",
              "modifiers": "left_control"
            }
          ]
        }
      ]
    }
  ]
}
{% endhighlight %}
<figure>
<figcaption class="caption">[파일 2] ~/.config/karabiner/assets/complex_modifications/mouse_space.json</figcaption>
</figure>

[파일 2]를 생성한다. [파일 2]는 Windows Mouse의 Wheel Scroll Key와 Size Key를 통해서 macOS에서 Work Space를 변경할 수 있도록 설정한다.

### 4. Karabiner-Elements의 Complex Modification Rules 설정

![[그림 1] Complex Modification Rules 설정전]({{site.baseurl}}/images/record/macOS_Keyboard_Mouse_Key/Karabiner-Elements_Complex_Modification_Rules_Before_Setting.PNG)

![[그림 2] Complex Modification Rules 설정후]({{site.baseurl}}/images/record/macOS_Keyboard_Mouse_Key/Karabiner-Elements_Complex_Modification_Rules_Before_Setting.PNG)

Karabiner-Elements에서 [파일 1], [파일 2]의 Complex Modification Rules을 적용한다. [그림 1]에서 "Add rule" Button을 눌러 설정한다.