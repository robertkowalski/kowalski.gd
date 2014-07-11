---
layout: post
title: "ES6 Features testen Teil 1: let und const"
date: 2013-02-28 17:49
keywords: Harmony, JavaScript, ECMAScript 6, ES6
description: Die Serie 'ES6 Features testen' geht auf neue ECMAScript Features ein, die schon heute in aktuellen Browsern testbar sind
tags: [ES6, JavaScript]
---

Die Serie "ES6 Features testen" berichtet über neue JavaScript Sprachfeatures die teilweise schon in Browsern implementiert sind.

ECMAScript, von dem JavaScript streng genommen eigentlich ein Dialekt ist, wird vom "TC39-Komitee" [standardisiert und weiterentwickelt.](http://www.ecma-international.org/publications/standards/Ecma-262.htm)

Mit der kommenden Version 6 - auch als "Harmony" betitelt - wird es viele neue Sprachfeatures für den Entwickler geben. Ein paar davon kann man heute schon ausprobieren, da viele Features schon in [Browsern](http://kangax.github.com/es5-compat-table/es6/) und Servern (z.B. node.js) implementiert wurden.

<!-- more -->

Getestet wurde dieser Blogartikel mit Firefox 19.

## let

Der Scope des reservierten Schlüsselworts `let` in JavaScript bezieht sich auf den jeweiligen Block - der Scope von Variablendeklarationen mit `var` dagegen auf den Scope einer Funktion.

Das Schlüsselwort `let` erlaubt uns somit zum Beispiel lokale Variablen innerhalb von Schleifen.

```javascript
var i = 20;

for (let i = 0; i < 5; i++) {
  console.log(i); // 1, 2, 3, 4
}

console.log(i); // 20
```

Zudem ist es mit `let` möglich lokale Variablen innerhalb eines Block Scopes deklarieren.

```javascript
var a = 5;

let (a = 6) {
  console.log(a); // 6
}

console.log(a); // 5

```

## const

Das neue Keyword `const` beschert uns Konstanten in JavaScript.

```javascript
const MY_CONSTANT = 4;
console.log(MY_CONSTANT); // 4

MY_CONSTANT = 5;
console.log(MY_CONSTANT); // 4
```

Wie man sieht - es tut sich was in JavaScript, mit dem noch nicht fertigen Harmony bzw. ES6 werden viele neue Features erwartet.
