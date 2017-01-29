---
title: Paper, Patent
category: Computer
---

{% assign docs = site.docs | where: 'category','Paper, Patent' | sort: 'title' %}
{% for doc in docs %}{% if doc.title != null %}
* [{{ doc.title }}]({{ site.baseurl }}{{ doc.url }})
{% endif %}{% endfor %}

