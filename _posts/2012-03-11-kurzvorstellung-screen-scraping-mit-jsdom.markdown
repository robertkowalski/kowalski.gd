---
layout: post
title: "Kurzvorstellung: Screen Scraping mit node & jsdom"
date: 2012-03-11 01:14
description: Kurzvorstellung von jsdom für node.js und wie man damit dieses Blog auf seine Shell holt.
keywords: "screen scraping, scraper, Robert Kowalski, node, node.js, JavaScript"
tags: [JavaScript, Node.js]

---

Ein sehr praktisches Tool ist [jsdom](https://github.com/tmpvar/jsdom), ein Modul von Elijah Insua für node.js.
Jsdom bringt das DOM zu node.js und es lassen sich tolle Screen Scraper und andere Tools für die Konsole bauen.

Man munkelt, einige geben sich damit sogar den aktuellen Fahrplan des jeweiligen Personen-Nahverkehrs auf ihrer Shell aus.

<!-- more -->

Ich möchte jsdom hier einmal ganz kurz vorstellen und zeigen, wie schnell ich die Titel der Artikel von Startseite
meines Blogs auf meiner Shell ausgeben kann.
Natürlich sind noch viele andere nützliche Szenarien oder Anwendungsfälle denkbar, jedoch sollte man das deutsche Urheberrecht im Hinterkopf
behalten.

Installation
------------

Man installiert jsdom mit Hilfe von npm:

{% highlight bash %}
$ npm install jsdom
{% endhighlight %}


Sollte man den Fehler bekommen ```node-waf``` würde fehlen, so sollte man das Paket ```nodejs-dev``` nachinstallieren.

Beispielprogramm
----------------

Wie bereits erwähnt wollen wir hier ganz schnell Elemente meines Blogs scrapen.

Ein typischer jsdom-Aufruf besteht als erstes immer aus der Zielurl.

Als zweite Angabe folgen dann gewünschte Libraries wie jQuery, die geladen werden können und zur Interaktion mit dem DOM benutzt werden.

Als letztes Argument folgt dann eine Callback-Funktion, die aufgerufen wird, wenn wir unser DOM und die Library geladen haben.

{% highlight javascript %}
var jsdom = require('jsdom');

jsdom.env('http://robert-kowalski.de', [
  'http://code.jquery.com/jquery-1.7.1.min.js'
], listAllArticles);

function listAllArticles(errors, window) {
  var $ = window.$;

  $('article').find('header')
    .find('a')
      .each(function(i, element) {
          console.log($(element).text());
      });
};
{% endhighlight %}

Und schon bekomme ich mit ``` $ node blogscraper.js ``` meine Artikeltitel auf der Startseite von robert-kowalski.de angezeigt:

<pre>
  Cross platform Test Driven Development (TDD) mit Jasmine, jQuery Mobile, Phonegap und node
  Private und Public in JavaScript
</pre>
