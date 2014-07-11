---
layout: post
title: "ES6 Features Draft"
date: 2013-03-01 13:20
comments: false
published: false
categories:
draft: true
---

## String.contains

Mit Hilfe neuer Methoden für Strings kann man in ES6 nun leicht herausfinden, ob ein String einen bestimmten Buchstaben oder eine Zeichenfolge enthält. Die Funktion ist dabei Case Sensitive.

```javascript
'My String'.contains('S');    // true
'My String'.contains('My');   // true
'My String'.contains('s');    // false
'My String'.contains('w');    // false
```

## Default parameter values / Vorgegebene Standartparameter

Default parameter values sind in vielen Sprachen schon lange ein alter Hut. Sie sorgen dafür, falls ein Parameter beim Aufruf nicht übergeben wird, dass dieser mit einem festgelegtem Standartwert befüllt ist.

Dies ist bisher zum Beispiel in PHP möglich:

```php
<?php
function myFunction($value = 'example') {
  echo $value;
}

myFunction(); // example
?>
```

Auch Ruby bietet die Möglichkeit von Standartparametern:

```ruby
def myFunction(value = 'example')
  puts value
end

myFunction() # example
```

Und hier das JavaScript Beispiel:

```javascript
function myFunction(value = 'example') {
  console.log(value);
}

myFunction(); // example
```

## ... (Rest und Spread)

`...` wird zwei Funktionen erfüllen:

 - Einmal als sogenannte Rest Parameter um "restliche Parameter" bei einem Funktionsaufruf zu definieren. Diese sind in einem vollwertigen Arrays hinterlegt.

 - Auch Array-Literale werden  vom `...`-Ausdruck erweitert, dort wird das Konstrukt als `spread` bezeichnet. Zusätzlich wird man die drei Punkte in Funktionaufrufen benutzen können, wenn das Sprachfeature komplett implementiert wurde.

### Rest

```javascript
function logWithRest(a, ...r) {
  var b = a.concat(r);
  console.log(b);
}

logWithRest([1], 2, 3, 4, 5); // [1, 2, 3, 4, 5]
```
Man beachte, dass die restlichen Parameter im Gegensatz zum "Array-like-Object" `arguments` in einem echtem Array sind.

Also kein

```javascript
var args = Array.prototype.slice.call(arguments);
```

mehr! Yippie!

### ... in Array-Literalen (Spread):

```javascript
var clothes = ['hat', 'jeans'];

var thingsToBuy = ['beer', ...clothes, 'food'];

console.log(thingsToBuy); // ["beer", "hat", "jeans", "food"]
```


## let

```javascript
for (let i = 0; i < 5; i++) {
  console.log(i); // 1, 2, 3, 4
}

console.log(i);   // ReferenceError: i is not defined
```

```ruby
['egg', 'bacon', 'salt'].each do |x|
  puts x # egg, bacon, salt
end

puts x   # NameError: undefined local variable or method `x' for #<Object:0x10de53298>
```

```javascript
{ let foo = "bar"; }
console.log(foo);   // ReferenceError: foo is not defined
```

## Convenience for Numbers

Because

```javascript
NaN == NaN // false

```

```javascript
Number.isFinite(Infinity); // false
Number.isFinite(42);       // true

Number.isNaN(NaN);         // true
Number.isNaN(42);          // false

Number.isInteger(1);       // true
Number.isInteger(4.2);     // false

Number.toInteger(4.6);     // 4
```

Und was ist mit dem globalen `isNaN` aus ES1?

```javascript
isNaN(undefined);         // true
isNaN({});                // true
isNaN('Duck');            // true

Number.isNaN(undefined);  // false
Number.isNaN({});         // false
Number.isNaN('Duck');     // false


```

Und `isFinite`?

```javascript
isFinite(true);        // true
Number.isFinite(true); // false
```

## Arrow functions
Bekannt aus C# und CoffeeScript.

Die "Fat arrow functions" verhalten sich wie Funktionen, allerdings können nicht mit `new` (kein Contructor) instanziiert werden und haben auch keinen `.prototype`.

Sie kennen auch keine `arguments`, ein Zugriff führt zu einem Typfehler.


```javascript

// no argument:
var sayHi = () => { console.log('hi!'); }
sayHi();                            // hi!

// one argument
var square = x => x * x;
square(3);                          // 9

// more than one argument:
var calcRectangle = (a, b) => a * b;
calcRectangle(2, 4);                // 8


var odds = [1, 3, 5];
var evens = odds.map(x => x + 1);

console.log(evens);   // [2, 4, 6]

```

Lexikalischer Scope - kein verändertes `this` durch `call` oder `apply`.

`this` bezieht sich immer auf die umgebende Funktion. (that = this)

```
var object = {
  method: function() {
    return function() {
      return this;
    };
  }
};

object.method()() === window;

// one "trick" to avoid this: that = this

var object = {
  method: function() {
    var that = this;
    return function() {
      return that;
    };
  }
};

object.method()() === object;



var object = {
  method: function() {
    return () => this;
  }
};

object.method()() === object;

```


## Probier's aus

Viele Plattformen unterstützen ES6 Features bereits teilweise:

### node

```
$ node --harmony
```

### Chrome / Chrome Canary
`chrome://flags` in die Adressleiste eingeben und "Experimental JavaScript" einschalten


### Firefox
In Firefox kann man die neuen Features ohne zusätzliche Einstellungen benutzen.

## Further Reading

 - http://wiki.ecmascript.org/doku.php?id=harmony:proposals
 - https://mail.mozilla.org/listinfo/es-discuss

