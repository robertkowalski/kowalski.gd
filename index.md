---
layout: page
title: robert kowalski
tagline: Supporting tagline
---
{% include JB/setup %}

<ul class="posts">
  {% for post in site.posts %}
    <li class="small-bordered">
      <span class="small-hide">{{ post.date | date_to_string }} &raquo; </span>
        <a href="{{ BASE_PATH }}{{ post.url }}">{{ post.title }}</a>
    </li>
  {% endfor %}
</ul>
