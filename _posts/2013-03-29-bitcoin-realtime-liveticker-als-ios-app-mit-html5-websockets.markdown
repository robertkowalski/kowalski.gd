---
layout: post
title: "Bitcoin Realtime Liveticker als iOS App mit HTML5 Websockets"
date: 2013-03-29 21:04
tags: [mobile, JavaScript, Cross-Platform]
---

Das Websocket-Protokoll ist eine relativ neue HTML5-Technologie. Im Prinzip ist es eine Vollduplexverbindung mit Hilfe eines Sockets. So müssen Clients nicht mehr regelmäßig beim Server anfragen um Updates vom Server zu bekommen, wodurch der gesamte Overhead beim Aufbau einer Verbindung entfällt.

<!-- more -->

Heute möchte ich eine relativ simple iOS Applikation mit Hilfe von Phonegap bauen um zu zeigen, wie einfach Websockets zu benutzen sind. Für den Produktionsbetrieb fehlt aber unter anderem die Behandlung von Fehlern, auch habe ich nicht getestet, wie sich der Akku des iPhone's bei einer Websocketverbindung verhält.

Bitcoin ist eine digitale Währung. Mt Gox bietet eine Websocket Api für ihren Kurs von Bitcoins an.

Der Kern der Anwendung besteht eigentlich aus diesem JavaScript:

```javascript
var result = document.querySelector('#result'),
    socket = new WebSocket('ws://websocket.mtgox.com:80/mtgox?Channel=ticker'),
    json;

socket.onmessage = function(event) {
  json = JSON.parse(event.data);
  result.innerText = json.ticker.last.display;
};
```
Im ersten Schritt holen wir uns das DOM-Element, in dem wir das Ergebnis anzeigen wollen.

Danach erstellen wir eine Verbindung zum Websocketserver, und wählen dabei den Channel für den Liveticker aus.

Bei jedem Ergebnis, was uns der Server schickt wird der onmessage Callback aufgerufen.

In `event.data` finden wir einen Text, den wir in ein JSON Objekt umwandeln und aus dem wir uns dann den `display`-Wert für den letzten Kurs holen und als `innerText` in das result-Element schreiben:


Ein wenig CSS dazu, fertig ist die Realtime Bitcoin iOS App.


<img src="/assets/images/bitcoin-liveticker.png" alt="Ein Bild der HTML5 Applikation auf dem iPhone" />

Das Xcode-Projekt findet ihr unter: <a href="https://github.com/robertkowalski/bitcoin-app-demo" rel="nofollow">https://github.com/robertkowalski/bitcoin-app-demo</a>

