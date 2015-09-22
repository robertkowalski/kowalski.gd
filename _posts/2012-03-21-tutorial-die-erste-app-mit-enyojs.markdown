---
layout: post
title: "Tutorial: Die erste App mit EnyoJS"
date: 2012-03-21 20:41
tags: [mobile, JavaScript, Cross-Platform]
---

EnyoJS ist ein JavaScript Framework, welches ursprünglich von HP für das Touchpad Tablet zur Erstellung von webOS-Apps benutzt wurde.
Mittlerweile ist es als Open-Source Cross-Platform-Lösung (Apache Lizenz) der Öffentlichkeit zugänglich gemacht worden und erinnert in der JavaScript lastigen Handhabung eher an Sencha statt an markup-lastige Frameworks wie jQuery Mobile. Mit Onyx ist einen Monat nach dem Core-Framework nun der erste Teil von Widgets für Enyo released worden.

<img style="position:relative;margin:10px;height:430px;float:right;" src="{{ site.url }}/assets/images/enyo_blog_article/3_-_App.png" alt="Screen Phonegap" /> Wir werden eine kleine App mit Hilfe von Enyo bauen und uns dabei das Framework genauer anschauen. Ziel ist eine App (Phonegap) für iPhone und Android. Doch auch deren Browser und letzendlich Desktop PCs können bedient werden.

Das heutige Thema wird vor allem die Weintrinker freuen, denn wir werden eine Weinverwaltung für unseren Weinkeller bauen. Natürlich werden auch die ganz frisch erschienenen Onyx Widgets benutzt. Wer kein Weintrinker ist, der kann die App leicht zu einer Verwaltung für andere Dinge adaptieren.

<!-- more -->

Enyo möchte mit dem Konzept von sogenannten *Kinds* Modularität und Kapselung erreichen. Mit Enyo entwickelt man zuerst im Web-Browser, später macht man dann Feinanpassungen für die jeweiligen Plattformen auf den jeweiligen Endgeräten wie zum Beispiel Smartphone oder Tablet.

Hallo Enyo
----------

Die einfachste Anwendung, die in Enyo denkbar ist, wäre wie in eigentlich allen Sprachen eine einfache "Hello World" Anwendung. Es liegt für jeden Teil des Tutorials Sourcecode vor, zur Referenz und im ersten Schritt als Template für unsere App, um schnell starten zu können.

<a href="https://github.com/robertkowalski/enyoJS-Bootcamp" rel="nofollow">github repository</a>.

<a href="https://github.com/robertkowalski/enyoJS-Bootcamp/downloads" rel="nofollow">github - download as zip/tarball</a>.

Wir starten unsere ```index.html``` aus ```1a - App Template und Hello Enyo```.

Mit Hilfe unserer Developer Konsole erstellen wir adhoc ein "Kind" in Enyo:

```javascript
new enyo.Control({content: "Hi Enyo!"}).renderInto(document.body);
```
![Developer Konsole Screenshot]({{ site.url }}/assets/images/enyo_blog_article/1_-_App_Template_-_Konsole.png "Developer Konsole Screenshot")

welches, wie wir sehen, direkt zu einem div rendert:

```html
<div class="enyo-fit" id="control2">Hi Enyo!</div>
```
![Developer Konsole Screenshot]({{ site.url }}/assets/images/enyo_blog_article/1_-_App_Template_-_html_inspector.png "HTML Inspector Screenshot")

Der Befehl ```renderInto()``` rendert ein Kind in einen bestimmten DOM-Knoten, in diesem Fall den body unseres HTML-Dokuments.

Nach diesem ersten schnellen, einfachen Einstieg wollen wir einmal ein richtiges Kind schreiben.

Dependencies mit depends.js
---------------------------

Wir erstellen schnell eine ```Bottle.js```, die wir in den Ordner ```source```  speichern und eine leere ```App.css``` im Ordner ```style```.

Wem dieser und die folgenden Schritte zu lästig sind: keine Bange, einfach das git repository auschecken und mit ```1b - App Template mit package.js``` im nächsten Kapitel weitermachen.

Nachdem wir unsere Dateien haben, erweitern wir unser Template um eine ```package.js```. Die ```package.js``` wird diese und alle weiteren CSS-Styles und den Sourcecode von unseren Kinds referenzieren. Zusätzlich dazu habe ich die neu erschienenen Onyx-Styles und Kinds hinzugefügt.

```javascript
﻿enyo.depends(
  "./enyo/onyx/onyx.js",
  "./enyo/onyx/onyx.css",
  "./style/App.css",
  "./source/Bottle.js"
);
```

Enyo wird die Dateien beim Start der Anwendung automatisch laden.

Die ```package.js``` laden wir einfach im head unserer ```index.html```, den Rest macht Enyo für uns:

```html
﻿<!doctype html>
<html>
  <head>
    <title>Enyo App Template</title>
    <script src="./enyo/enyo.js"></script>
    <link href="./enyo/enyo.css" rel="stylesheet" type="text/css" />
    <script src="./package.js"></script>
  </head>
  <body>
    <script>

    </script>
  </body>
</html>
```

Zu finden ist das ganze unter ```1b - App Template mit package.js``` und wird die Basis für all unsere weiteren Experimente sein.

Die Weinflasche
---------------

Wir wollen nun unser erstes komplettes Kind schreiben. In unserer Weinlagerverwaltung liegen Weinflaschen. Jede Weinflasche stellt eine Entität in unserem Weinkeller dar. Wir modellieren nun also zuerst eine Flasche, jede Flasche hat ein Jahr sowie einen Namen. Zu finden ist alles in ```2a - Der Wein```.

```javascript
enyo.kind({
  name: "wine.Bottle",
  kind: enyo.Control,
  classes: "onyx",
  style: "padding: 10px",
  published: {
    wineYear: "",
    wineName: ""
  },
  components: [
    { tag: "span", name: "wineYear", style: "margin-right: 10px" },
    { tag: "span", name: "wineName", style: "margin-right: 10px" },
  ],
  create: function() {
    this.inherited(arguments);
    this.wineBottleChanged();
  },
  wineBottleChanged: function() {
    this.$.wineYear.setContent(this.wineYear);
    this.$.wineName.setContent(this.wineName);
  }
});
```
Ein Kind wird in Enyo mit Hilfe von ```enyo.kind``` definiert. Dieses Kind hier erbt wiederrum vom Kind ```enyo.Control```. Benannt wurde das Kind ```wine.Bottle```. Der Punkt sorgt hier für ein Namespacing.

Mit ```classes``` und ```style``` gibt man in Enyo CSS-Klassen beziehungsweise CSS-Styles für die Kinds an.

Kinds können weitere Kinds in sich schachteln. Diese können auch wieder weitere Kinds in sich schachteln.
Verschachtelte Elemente werden unter ```components``` eingetragen.

Wir haben hier unter ```components``` zwei Elemente, die als span-Elemente rendern sollen (festgelegt mit ```tag: "span"```).

Die beiden Elemente haben jeweilig die Namen wineYear und wineName, mit denen man später auf sie zugreifen kann. Innerhalb von unserem Kind greift man auf diese Elemente mit Hilfe von ```this.$.``` zu. Später dazu mehr.

Beim Erstellen eines Kinds wird die Methode ```create``` automatisch aufgerufen. Es gibt auch die Methoden ```contructor``` und ```rendered```, die überschrieben werden könnten, aber diese Methoden werden wir hier nicht verwenden.

Wir rufen über die ```create```-Methode per ```this.wineBottleChanged();```  die Methode ```wineBottleChanged``` auf, hier passiert sehr viel: wir adressieren mit ```this.$``` und den von uns festgelegten Namen unsere Komponenten.

```javascript
this.$.wineName.setContent(this.wineName);
```

Wir ändern ihren Inhalt mit Hilfe von ```setContent``` auf die Werte unserer öffentlichen, nach außen bereitgestellten Eigenschaften aus ```published```. Die Werte in ```published``` können von außen gesetzt und gelesen werden.


Als Referenz ist das ganze unter ```2a - Der Wein``` zu finden.

### Testrunde

Nachdem wir den Code in unsere ```Bottle.js``` geschrieben haben, können wir mit

```javascript
new wine.Bottle({
  wineYear: 1999,
  wineName: "Chardonnay"
}).renderInto(document.body);
```
eine Weinflasche erstellen.

Testweise können wir den Befehl in den script tags unserer index.html angegeben, die vorher leer gelassen wurden. Nun können wir die index.html im Browser öffnen um das Kind weiter zu untersuchen, hier noch einmal der Ablauf unseres Programms:

Wir geben das Jahr und einen Namen für unseren Wein an, unter ```published``` wurden diese öffentlichen Eigenschaften unseres Enyo Kinds festgelegt. Bei der Erstellung wird die ```create```-Methode aufgerufen und damit die Inhalte der öffentlichen Eigenschaften in den DOM geschrieben.

![Developer Konsole Screenshot]({{ site.url }}/assets/images/enyo_blog_article/2_-_Wein.png "Eine Flasche Wein Screenshot")

### Event Binding (Wein trinken)

Manchmal trinkt man einen Wein aus seinem Keller. Das wollen wir mit unserem Kind auch abbilden.

Die Idee ist ein "entfernen" Button unter den ```components``` des Kinds hinzuzufügen. Wir benutzen den onyx-Button aus dem onyx-Widget-Pack. Auf dem Button soll "getrunken" stehen und er bekommt die CSS-Klasse ```onyx-negative```, die den Button rot färbt.

Mit ```ontap``` registrieren wir ein Event, das aufs Antippen reagiert. Enyo kennt viele Events, z.B. auch das beliebte "Wischen"/Swipe.

```
{ kind: "onyx.Button", content: "getrunken",
  classes: "onyx-negative", ontap: "drinkWine" }
```

Wenn man diesen Button drückt, soll die Methode ```drinkWine``` ausgeführt werden:

```javascript
drinkWine: function(inSource, inEvent) {
  this.destroy();
}
```

Das ontap-Eventbinding referenziert auf die Methode ```drinkwine```. Mit ```this.destroy``` zerstört sich das Kind selbst.

Hier das erweiterte Kind im Gesamten:

```javascript
enyo.kind({
  name: "wine.Bottle",
  kind: enyo.Control,
  classes: "onyx",
  style: "padding: 10px",
  tag: "div",
  published: {
    wineYear: "",
    wineName: ""
  },
  components: [
    { tag: "span", name: "wineYear", style: "margin-right: 10px" },
    { tag: "span", name: "wineName", style: "margin-right: 10px" },
    { kind: "onyx.Button", content: "getrunken",
      classes: "onyx-negative", ontap: "drinkWine" }
  ],
  create: function() {
    this.inherited(arguments);
    this.wineBottleChanged();
  },
  wineBottleChanged: function() {
    this.$.wineYear.setContent(this.wineYear);
    this.$.wineName.setContent(this.wineName);
  },
  drinkWine: function(inSource, inEvent) {
    this.destroy();
  }
});
```

Den Beispielcode findet man in ```2b - Wein trinken```.

Getter und Setter in Enyo
--------------------------

Enyo liefert automatisch Getter und Setter für seine internen Kinds, beispielsweise:

```javascript
.setContent();
.getContent();
.getAttribute();
.setAttribute();
```

Doch auch für die von uns festgelegten public-Properties werden automatisch Setter und Getter von Enyo erstellt:

```javascript
var foo = new wine.Bottle({wineYear: 1999, wineName: "Chardonnay"});

foo.getWineYear(); // 1999
foo.setWineYear(2021);
foo.getWineYear(); // 2021
```


<h2 style="padding-top: 1em;">Der Weinkeller</h2>


Unsere Flaschen werden von einem Weinkeller beherbergt. Also erstellen wir eine Datei mit dem Namen ```Cellar.js``` und fügen die Datei der ```package.js``` hinzu:

```javascript
﻿enyo.depends(
  "./enyo/onyx/onyx.js",
  "./enyo/onyx/onyx.css",
  "./style/App.css",
  "./source/Bottle.js",
  "./source/Cellar.js"
);
```

Nach so viel Basic Input zu Enyo ist der Weinkeller für die Flaschen schnell geschrieben:

```javascript
enyo.kind({
  name: "wine.Cellar",
  classes: "onyx",
  style: "padding: 10px;",
  components: [
    { kind: "onyx.Input", name: "inputWineYear", placeholder: "Jahr",
      classes: "center" },
    { kind: "onyx.Input", name: "inputWineName", placeholder: "Name",
      classes: "center" },
    { kind: "onyx.Button", content: "hinzufügen",
      classes: "onyx-affirmative center", ontap: "addWine",
      style: "margin-top: 10px;" },
    { name: "groupbox", style: "padding-top: 10px;", kind: "onyx.Groupbox",
    showing: false, components: [
      {kind: "onyx.GroupboxHeader", content: "Weinliste"},
      { name: "cellar" }
    ]},
  ],
  create: function() {
    this.inherited(arguments);
  },
  addWine: function(inSource, inEvent) {
    var year = this.$.inputWineYear.getNodeProperty("value"),
        name = this.$.inputWineName.getNodeProperty("value");
    if (year !== "" &&  name !== "") {
      this.createComponent({
        kind: wine.Bottle,
        container: this.$.cellar,
        wineYear: this.$.inputWineYear.getNodeProperty("value"),
        wineName: this.$.inputWineName.getNodeProperty("value")
      });
      // neu rendern
      this.$.cellar.render();
      // gruppe sichtbar machen
      if (this.$.groupbox.getShowing() === false) {
        this.$.groupbox.setShowing(true);
      }
      // inputfelder zurücksetzen
      this.$.inputWineName.setNodeProperty("value", "");
      this.$.inputWineYear.setNodeProperty("value", "");
    }
  }
});
```

Wir definieren zwei Input Felder mit Kinds aus dem Onyx Theme. Alternativ wäre auch ganz normal

```javascript
{ tag: "input", name: "inputWineName" }
```

usw. möglich.

Wir haben eine Gruppe mit Header, hier wird uns sehr viel von Enyo geschenkt. Die Gruppe ist anfangs nicht sichtbar, erreicht wird dies durch ```showing: false```

```javascript
{ name: "groupbox", style: "padding-top: 10px;",
  kind: "onyx.Groupbox", showing: false, components: [
```

Der Header in der Gruppe würde beim Start der App stören, wenn noch keine Weine vorhanden sind.

Beim Drücken des "hinzufügen"-Buttons rufen wir unsere Methode ```addwine``` auf.

Nachdem hier überprüft wurde, dass beide input-Felder mit Inhalt gefüllt sind, erstellen wir eine neue Weinflasche innerhalb von unserem Kind mit dem Namen ```cellar```. Wir holen die Werte aus den Kinds mit ```this.$.inputWineYear.getNodeProperty("value")``` und übergeben sie an die published-Properties unseres Weinflaschen-kinds.

```javascript
this.createComponent({
    kind: wine.Bottle,
    container: this.$.cellar,
    wineYear: this.$.inputWineYear.getNodeProperty("value"),
    wineName: this.$.inputWineName.getNodeProperty("value")
});
```

Danach rendern wir alles neu und machen die unsichtbare Gruppe sichtbar, da wir nun Einträge vorzuweisen haben. Danach setzen wir die Inputfelder wieder zurück.

```javascript
// neu rendern
this.$.cellar.render();
// gruppe sichtbar machen
if (this.$.groupbox.getShowing() === false) {
    this.$.groupbox.setShowing(true);
}
// inputfelder zurücksetzen
this.$.inputWineName.setNodeProperty("value", "");
this.$.inputWineYear.setNodeProperty("value", "");
```


Zuletzt ist noch die CSS-Klasse center zu beachten, die in der Datei ```App.css``` im Ordner ```style``` Einzug gehalten hat.

![Screen Phonegap]({{ site.url }}/assets/images/enyo_blog_article/3_-_App.png "Screen Phonegap")

**Die App in einer Phonegap "Shell"**

Ausblick
--------

Letzendlich könnte man dieses kleine Weinkeller Beispiel bis ins unendliche aufblähen. Ich belasse es hierbei, dennoch drängt sich ein Datenspeicher zur Zwischenspeicherung unser Daten auf dem Client und einem Server quasi direkt auf.


Links
-----

<a href="https://github.com/robertkowalski/enyoJS-Bootcamp" rel="nofollow">Sourcecode auf github</a>.

[Enyo Javascript Framework](http://enyojs.com/)

<img src="http://vg09.met.vgwort.de/na/e8931362482b4da680fec6b5110bcb17" width="1" height="1" alt="">
