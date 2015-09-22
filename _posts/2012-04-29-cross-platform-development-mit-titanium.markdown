---
layout: post
title: "Cross-Platform-Development mit Titanium"
date: 2012-04-30 18:20
description: Kurzer Blick auf Appcelerator Titanium mit Entwicklung einer ersten Beispiel-App
keywords: "Titanium, iPhone, App, mobile, Robert Kowalski, JavaScript"
tags: [mobile, JavaScript, Cross-Platform]
---

Nachdem ich mir Anfang 2011 schon einmal Titanium von Appcelerator (nur in Bezug auf Android) angesehen hatte, wollte ich mir nun noch einmal ein Bild von Titanium machen. Laut einer Präsentation bei der JavaScript Usergroup und nach Austausch mit Kollegen soll sich seit damals viel getan haben.

<!-- more -->

Ich baue eine kleine App, ausschließlich erst einmal für das iPhone: ein Kollege fotografiert sehr gut und hat einen sehr empfehlenswerten [flickr-Fotostream](http://www.flickr.com/photos/zanthia/). Warum also nicht eine Fotostream App bauen und dabei Titanium besser kennenlernen?

Entwicklung
-----------

Für Titanium Apps ist JavaScript die Ausgangsbasis.

Titanium Apps benutzen mit Hilfe von JavaScript-Code native iOS oder Android Komponenten, der JavaScript-Code wird von einem JavaScript-Interpreter interpretiert. Das Konzept ist somit etwas anders als bei Phonegap Apps, die in einem WebView ausgeführt werden.

Titanium kann um weitere native Komponenten erweitert werden, die zum Beispiel in Objective C geschrieben sind und über eine Verbindungseinheit in JavaScript besitzen. Dies ist grundsätzlich auch bei Phonegap möglich. Doch wie bereits erwähnt laufen Phonegap Apps hauptsächlich in einem WebView, ohne native UI-Elemente.

Bei Titanium helfen Module beim Gliedern der App. Hier finden die aus CommonJS und auch aus node.js bekannten Module mit ```exports``` und ```require``` Anwendung.

```javascript
// Definition des Moduls in der ExampleFile.js

var exampleModule = function() {
    return "I am a Module";
};

module.exports = exampleModule;

```

```javascript
// Import und Benutzung in der Foo.js

var exampleFunction = require('./ExampleFile');

exampleFunction(); // => "I am a Module"
```

Die einzelnen Module lassen sich dann bestimmt auch relativ gut Unit-Testen. Ein festes Konzept oder Integration von Unit-Tests im Titanium Framework habe ich leider nicht entdecken können.

Im allgemeinen war der Prototyp relativ schnell gehackt. Die App ist, ohne auf jedes Detail einzugehen, im Prinzip ein AJAX-Request und die Erstellung einer Coverflow-Gallerie.

```javascript
// AJAX Client
var xhr = Titanium.Network.createHTTPClient();

xhr.onload = function() {
     // Antwort-JSON verabeiten, Coverflow erstellen,
     // Activity Spinner anhalten, Eventhandler registrieren...
};
```

```javascript
var view = Ti.UI.iOS.createCoverFlowView({
    images : preview,
    backgroundColor : '#000',
    top: '30px',
    height: '90%'
});

view.addEventListener('change', function(e) {
    labelTitle.setText(images[e.index].title);
});

view.addEventListener('click', function(e) {
    // Detail-View öffnen etc.
});

```
Der Event-Listener ```change``` kümmert sich um neue Titel bei wischen über die Bilder - der Event-Listener, der auf das ```click``` -Event lauscht, ruft eine Detailseite auf, die eine etwas größere Version des Bildes anzeigt.


iOS & Android - alles gleich?
-----------------------------

Auch wenn Titanium mit "einer Codebasis für viele Plattformen" wirbt, gibt es dennoch einige Unterschiede.

Die Kompilierungszeit ist mit dem iOS SDK und iOS Emulator sehr angenehm im Gegensatz zu Android, was aber an dem Android Emulator und des Kompilierungvorgangs des Android SDKs liegt und kein Verschulden von Titanium ist.

Es gibt für iOS einige UI-Komponenten, die nicht für Android verfügbar sind. Will man also mit der exakt gleichen Codebasis Android und iOS bedienen, muss man sich für die Android Version etwas anderes einfallen lassen und eine Sondervariante mit Weiche im Code einbauen.


Fazit
-----

Innerhalb von ein paar Stunden hatte ich Titanium installiert, meinen Flickr API Key beantragt und den ersten Prototypen zur Photo-App von Zanthia's Photostream fertig. Der von mir benutzte Coverflow für die Bildergalerie ist für Android nicht verfügbar - hier müsste für Android eine andere Lösung gefunden werden.

Die App war schnell fertig und läuft super. Das iOS Element "Coverflow" hätte man mit HTML5 nicht so performant realisieren können.

Für Prototypen, sehr kleine Apps oder Teams mit zusätzlichen nativen Entwicklern also durchaus eine Alternative.


Demovideo
---------

<iframe width="420" height="315" src="http://www.youtube.com/embed/ofZ1461cpf8" frameborder="0" allowfullscreen></iframe>

Sourcecode
----------

Wie immer gibt es den
<a href="https://github.com/robertkowalski/titanium-flickr/blob/master/Resources/ui/handheld/ApplicationWindow.js" rel="nofollow">Sourcecode auf github</a>. Meinen Flickr API Key habe ich aus dem Code entfernt.

<img src="http://vg09.met.vgwort.de/na/aae1049f37ad4d83913ba9bde1d02c69" width="1" height="1" alt="">
