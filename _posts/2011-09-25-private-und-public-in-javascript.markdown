---
layout: post
title: "Private und Public in JavaScript"
tags: [JavaScript]
---
Heute werfen wir einen Blick auf Public und Private Methoden in JavaScript, denn viele Entwickler denken, dass es keine privaten Methoden/Eigenschaften in JavaScript gibt.

<!-- more -->

Man schreibt nur kein private vor die Methoden / Eigenschaften, wie in vielen anderen Sprachen, die klassenbasiert sind.


Schauen wir uns das ganze mit dem Beispiel eines Top-Spions an, das man leicht in der Chrome Konsole oder im Firebug ausprobieren kann:

{% highlight javascript %}
var Spy = function() {

  // @private
  var name = 'Hans';
  var setName = function(n) {
    name = n;
    return 'Neuer Name: '+ name;
  }
  var getName = function() {
    return name;
  }

  //Interface
  return {
    // @public
    name: 'Peter',
    setPrivateName: function(name) {
      return setName(name);
    },
    // hat Zugriff auf die privaten Variablen / Methoden
    getPrivateName:  function() {
      return 'Private Eigenschaft: '+ name + " - Privater Getter: " + getName();
    }
  }
};
{% endhighlight %}

Peter ist nämlich Geheimagent und hat einen Namen, sowie einen Decknamen.
Doch er fliegt während einer Operation auf und benötigt einen neuen Namen.

{% highlight javascript %}
var s = new Spy();
// => undefined

s.name;
//=>  "Peter"

// Versuch auf private Methode zuzugreifen
s.getName();
//=> TypeError: Object #<Object> has no method 'getName'
s.setName('Georg der Spion');
// => TypeError: Object #<Object> has no method 'setName'

// Über das Interface
s.getPrivateName();
// => "Private Eigenschaft: Hans - Privater Getter: Hans"
s.setPrivateName('Tom');
//  => "Neuer Name: Tom"
s.name;
// => "Peter"
s.getPrivateName();
// => "Private Eigenschaft: Tom - Privater Getter: Tom"
{% endhighlight %}


Letzendlich hoffe ich, ich konnte einen kleinen Einblick in JavaScript vermitteln.
