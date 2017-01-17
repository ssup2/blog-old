---
title: Paper, Patent
---

{% assign docs = site.docs | where: 'category','paper_patent' | sort: 'title' %}
{% for doc in docs %}{% if doc.title != null %}
<li><a href="{{ site.baseurl}}{{ doc.url }}">{{ doc.title }}</a></li>
{% endif %}{% endfor %}

