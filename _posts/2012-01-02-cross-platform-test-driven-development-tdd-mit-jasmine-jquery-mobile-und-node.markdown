---
layout: post
title: "Cross-Platform Test Driven Development (TDD) mit Jasmine, jQuery Mobile, Phonegap und node"
date: 2012-01-02 22:42
description: Testgetriebene Entwicklung in JavaScript, die in einer Phonegap App und node.js Service aufging
keywords: "Phonegap, Jasmine, Robert Kowalski, node, node.js, TDD, Test Driven, JavaScript"
tags: [mobile, JavaScript, Node.js, tdd, Cross-Platform]

---
Über die Feiertage packte mich mein Entwicklerdrang, einmal eine WebApp / App komplett Testdriven zu schreiben
und dabei [Jasmine von Pivotal Labs](http://pivotal.github.com/jasmine/) in der Praxis auszuprobieren.

Herausgekommen ist eine TDD entwickelte Phonegap App sowie ein node Webservice.

<!-- more -->

Wenn man neues Terrain betritt, ist es ganz praktisch, ein nicht zu großes Projekt zu wählen, mit dem man erste Erfahrungen sammeln kann. So fiel meine Wahl auf den Sensor in der Tür des CCC Hamburg, der den Türstatus für alle ohne Schlüssel zu den Räumlichkeiten übermittelt. Zudem gibt es einen Dienst der die Anzahl der verbundenen DHCP Clients ins Netz stellt.

Für das TDD wählte ich wie schon erwähnt Jasmine von Pivotal Labs, das wie ich finde eine sehr schöne, deklarative Syntax besitzt.

Beim Test Driven Development schreibt man erst den Test und danach den Code, optimalerweise entsteht der Produktivcode im Test selbst und man baut im Anschluss seine Methode daraus.

Die wohl am meisten genutzte Funktion ist ``` .toEqual() ```

Ein typischer fertiger Test sieht dann so aus:

{% highlight javascript %}
it('should add a leading 0 to numbers under 10', function() {
  expect(App.dateHelper(1)).toEqual('01');
  expect(App.dateHelper(10)).toEqual('10');
});
{% endhighlight %}

** Das Entwickeln ist zwar erst ungewohnt, aber mit der Zeit entwickelt man schneller, produziert weniger Bugs und geht gelassen mit unerwarteten Änderungen am Code um. **

Als Cross Platform Lösung habe ich mich an jQuery Mobile bedient, anlässlich des 1.0 Releases.
Es ging anfangs schnell von der Hand, hinterließ aber einen etwas unreifen Eindruck.

Verschiedene Plattformen mit einer Codebasis bedienen
-----------------------------------------------------

Als ich meine <a href="https://github.com/robertkowalski/doorisMobile-base" rel="nofollow">Codebasis</a>
hatte, installierte ich XCode und Phonegap und hatte nach kurzer Zeit meine mobile
<a href="https://github.com/robertkowalski/doorisMobile-phonegap" rel="nofollow">iPhone App</a>
im iPhone Simulator. Im Footerbereich musste ich noch etwas CSS anpassen, was im Browser so nicht ersichtlich war,
aufgrund fehlerhaften Verhaltens oder Doku von jQuery Mobile.

Danach habe ich einen <a href="https://github.com/robertkowalski/doorisMobile-node" rel="nofollow">node Webservice</a> aufgesetzt, mit Hilfe des berühmten Express.

<s>Den Webservice findet man mittlerweile auf heroku.</s>

Durch die vorhandene Codebasis für die Phonegap App musste ich die Views nur noch an die Jade Template Engine anpassen und Cache Manifeste erstellen. Außerdem mussten die Textfiles, die von anderen Servern kamen, wegen Cross-Site-Origin Sicherheitsregeln mit Hilfe der node app "geproxied" werden.


Lessons Learned
---------------

**Vorteile:**

Ich bin mit einer Codebasis gestartet, die ich dann ohne viel Aufwand als App aufs iPhone mit Phonegap bringen konnte und später damit einen node.js Webservice bei heroku aufsetzen konnte.

Jasmine hat sich auch in der Praxis eines Projektes als solides, ausgewachsenes Testframework bewiesen, das durch selbstsprechende Syntax überzeugt.


**Nachteile:**

Ich habe das mobile Framework jQuery Mobile ausprobiert, das trotz 1.0 Release einige Bugs aufweist
(Buttons im Footer bei mir, **über 500 Issues auf github**). Außerdem zerstört das ein- und ausblenden des Headers
und des Footers beim scrollen das "native-Experience" komplett.

Auch scheint mir die Größe von jQuery und jQuery mobile für eine mobile Seite zu groß, wenn man bedenkt, daß viele mobile Web User in EDGE/GPRS Gegenden unterwegs sind.

Sourcecode
----------

+ <a href="https://github.com/robertkowalski/doorisMobile-base" rel="nofollow">Code der BasisApp</a>

+ <a href="https://github.com/robertkowalski/doorisMobile-phonegap" rel="nofollow">Code für Phonegap</a>

+ <a href="https://github.com/robertkowalski/doorisMobile-node" rel="nofollow">Code für node</a>


Andere Links
------------

[Jasmine im Browser ausprobieren](http://tryjasmine.com)

