---
title: Record
category: Computer
---

{% assign docs = site.docs | where: 'category','record' | sort: 'title' %}
{% for doc in docs %}{% if doc.title != null %}
<li><a href="{{ site.baseurl}}{{ doc.url }}">{{ doc.title }}</a></li>
{% endif %}{% endfor %}

