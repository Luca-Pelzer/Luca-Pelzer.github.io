---
title: "LearnTogether bauen: Weil alleine Lernen langweilig ist"
date: 2025-12-16
draft: false
tags: ["nextjs", "typescript", "socket.io", "multiplayer", "bildung", "projekt", "prüfungsvorbereitung"]
categories: ["Projekte", "Entwicklung"]
description: "Wie ich eine Echtzeit-Multiplayer-Lernplattform für die IHK-Prüfungsvorbereitung gebaut habe, komplett mit Duellen, Rennen und viel zu vielen Karteikarten."
---

# LearnTogether bauen: Weil alleine Lernen langweilig ist

**TL;DR**: Ich bereite mich auf die IHK-Abschlussprüfung (Fachinformatiker) vor, hatte keine Lust mehr auf PDFs und habe stattdessen eine Multiplayer-Lern-App gebaut. Mit Karteikarten, Quiz, Duellen, Rennen und einem realistischen Prüfungssimulator. Produktive Prokrastination vom Feinsten. Ausprobieren: [learn.engels.wtf](https://learn.engels.wtf).

---

## Das Problem: Tod durch PDF

Wisst ihr, was unglaublich langweilig ist? Zum 47. Mal dasselbe PDF für eine Prüfung durchlesen.

Ich bereite mich gerade auf die IHK-Abschlussprüfung zum Fachinformatiker für Systemintegration vor, und ich sag euch—die offiziellen Lernmaterialien sind ungefähr so spannend wie Farbe beim Trocknen zuzuschauen. An einer beigen Wand. In einem fensterlosen Raum.

Ich habe versucht:
- PDFs zu lesen (eingeschlafen)
- Papier-Karteikarten zu machen (verloren)
- Anki zu benutzen (zu hässlich, kämpft mich)
- Mit Freunden zu lernen (wir haben am Ende über alles geredet außer der Prüfung)

Dann hatte ich einen Gedanken: **Was wäre, wenn Lernen tatsächlich... Spaß machen würde?**

Und was, wenn ich gegen Freunde antreten könnte, anstatt alleine zu leiden?

> **Produktivitätstipp**: Wenn du beim Lernen prokrastinierst, bau einfach eine komplette Lernplattform. Das zählt doch auch als Lernen, oder? Oder?

---

## Was ich gebaut habe

**LearnTogether** ist eine Full-Stack Multiplayer-Lern-App mit 5 Spielmodi:

### 🃏 Karteikarten (Solo)
Klassische Lernkarten zum Umdrehen. Klicken zum Aufdecken, als "Gewusst" oder "Muss ich üben" markieren. Die App merkt sich, welche Karten dir schwerfallen.

### ❓ Quiz (Solo)
Multiple-Choice-Fragen mit sofortigem Feedback. Falsch? Hier ist die Erklärung. Richtig? Dopamin-Kick.

### ⚔️ Duell (Multiplayer, 2-4 Spieler)
Hier wird's spannend. Alle sehen dieselbe Frage, haben 20 Sekunden zum Antworten. Punkte für richtige Antworten, Bonus für Schnelligkeit. Rundenbasiert, damit alle mitmachen—kein Verstecken in der letzten Reihe.

### 🏁 Rennen (Multiplayer, 2-4 Spieler)
Wer zuerst richtig antwortet, gewinnt die Runde. Aber Achtung: **Wenn du falsch antwortest, bist du für diese Frage gesperrt.** Hohes Risiko, hohe Belohnung. Freundschaften wurden getestet.

### 📝 Prüfungsmodus (Solo)
Das Herzstück. Eine realistische IHK-Prüfungssimulation mit:
- 7 verschiedenen Fragetypen (Multiple Choice, Zuordnung, Reihenfolge, Lückentext, Berechnungen...)
- 90-Minuten-Timer (wie in der echten Prüfung)
- Deutsches Notensystem (1-6, wobei 1 am besten ist)
- Detaillierte Ergebnisauswertung

Ich habe vermutlich mehr Zeit mit dem Bauen verbracht als mit dem eigentlichen Lernen. Keine Reue.

---

## Der Tech Stack

- **Next.js 14** mit App Router
- **TypeScript** (weil ich meine Fehler lieber beim Kompilieren sehe als um 2 Uhr nachts)
- **Tailwind CSS** fürs Styling (Dark Mode als Standard, natürlich)
- **Socket.io** für Echtzeit-Multiplayer
- **PM2** für Prozessmanagement
- **Caddy** als Reverse Proxy

### Warum Socket.io?

Damit Multiplayer sich flüssig anfühlt, braucht man bidirektionale Echtzeit-Kommunikation. Wenn Spieler A antwortet, muss Spieler B das *sofort* sehen. HTTP-Polling würde sich träge anfühlen.

Socket.io kümmert sich um:
- Raum-basierte Spielsitzungen (jedes Spiel bekommt einen eigenen Raum)
- Event-gesteuerte Updates (Antwort abgeschickt → an alle Spieler senden)
- Automatische Wiederverbindung (weil WLAN unzuverlässig ist)
- Graceful Fallback auf Long-Polling wenn WebSockets nicht funktionieren

Der Server ist die einzige Wahrheit für den Spielzustand. Kein Schummeln durch Client-Inspektion!

---

## Interessante Herausforderungen

### 1. Server-synchronisierter Fortschritt

Ich wollte, dass der Fortschritt geräteübergreifend funktioniert. Am Handy einloggen, am Laptop weitermachen.

Lösung: Fortschritt in JSON-Dateien auf dem Server speichern, nach Spielername sortiert.

```typescript
// Einfach aber effektiv
const progressPath = path.join(DATA_DIR, `${playerName}.json`);
await fs.writeFile(progressPath, JSON.stringify(progress, null, 2));
```

Keine Datenbank nötig bei dieser Größe. Nur Dateien. Manchmal ist einfach besser.

### 2. Schwache Karten tracken

Die App merkt sich Karten, die du als "Muss ich üben" markierst und bietet einen eigenen Wiederholungsmodus. Das ist quasi Spaced Repetition light—fokussier dich auf das, was du nicht weißt.

Ich habe mehr "schwache Karten" als mir lieb ist.

### 3. Multiplayer State Management

Spielzustand über mehrere Clients zu verwalten ist knifflig. Race Conditions sind real, wenn 4 Leute gleichzeitig antworten.

Lösung: Alles auf dem Server zentralisieren.

```typescript
socket.on('answer', ({ answer }) => {
  const game = games.get(roomId);
  game.answers.set(socket.id, answer);
  
  // Erst weitermachen wenn alle geantwortet haben
  if (game.answers.size === game.players.length) {
    const results = calculateScores(game);
    io.to(roomId).emit('roundResult', results);
  }
});
```

Der Server wartet auf alle Antworten, berechnet Punkte, dann sendet er die Ergebnisse. Keine clientseitige Punktemanipulation möglich.

### 4. Sieben Fragetypen für den Prüfungsmodus

Die echte IHK-Prüfung hat verschiedene Frageformate. Ich habe implementiert:

| Typ | Eingabe | Bewertung |
|-----|---------|-----------|
| Multiple Choice | Radio Buttons | Alles oder nichts |
| Multiple Select | Checkboxen | Teilpunkte |
| Lückentext | Texteingabe | Fuzzy Matching |
| Zuordnung | Drag-and-Drop Paare | Pro-Paar-Bewertung |
| Reihenfolge | Drag zum Sortieren | Sequenz-Matching |
| Berechnung | Zahleneingabe | Toleranz-basiert |
| Freitext | Textarea | Keyword-Matching |

Jeder Typ hat seine eigene React-Komponente und Bewertungslogik. Die Zuordnung und Reihenfolge mit Drag-and-Drop zu bauen hat besonders Spaß gemacht.

---

## Inhalte: Der eigentliche Lernteil

Ich habe Inhalte für 3 prüfungsrelevante Themen erstellt:

| Thema | Karteikarten | Quiz | Prüfung |
|-------|--------------|------|---------|
| 💾 Speichersysteme & Backup | 35 | 35 | 20 |
| ☁️ Cloud Computing | 32 | 24 | - |
| 🐳 Virtualisierung & Container | 40 | 22 | - |

Das sind **107 Karteikarten**, **81 Quizfragen** und **20 Prüfungsfragen** mit ausführlichen Erklärungen.

All diese Inhalte zu schreiben war ehrlich gesagt der zeitaufwändigste Teil. Aber hey, Erklärungen zu schreiben warum RAID 5 mindestens 3 Festplatten braucht, hat mir definitiv geholfen es besser zu verstehen.

---

## Deployment

Die App läuft in einem LXC-Container auf meinem Proxmox-Homelab:

```bash
# Next.js App bauen
npm run build

# Mit PM2 für Prozessmanagement starten
pm2 start ecosystem.config.js

# Caddy kümmert sich um HTTPS auf dem Host
# learn.engels.wtf → Reverse Proxy zum Container
```

Läuft seit Tagen stabil. PM2 startet automatisch neu wenn es abstürzt (ist es nicht).

---

## Fehler die ich gemacht habe (damit ihr sie nicht macht)

### 1. Vergessen Punkte beim Rematch zurückzusetzen
Erste Version: Neues Duell starten, und du hattest noch deine Punkte vom letzten Spiel. Ups.

### 2. Client-seitiges Mischen
Anfangs wurden Fragen auf dem Client gemischt. Problem: Im Multiplayer hatte jeder eine andere Reihenfolge. Jetzt mischt der Server einmal und schickt allen dieselbe Reihenfolge.

### 3. Fortschritt nur bei Abschluss gespeichert
User machten 30 Karteikarten, schlossen den Tab, alles weg. Jetzt wird nach jeder einzelnen Karte/Frage gespeichert.

### 4. Keine Ladezustände
Socket.io-Verbindungen brauchen einen Moment. Ohne Ladezustände sahen User einen leeren Bildschirm und dachten es wäre kaputt.

### 5. Hardcodierte Localhost-URLs
Funktionierte super auf meinem Rechner. Funktionierte gar nicht in Produktion. Klassiker.

---

## Was ich gelernt habe

1. **Socket.io ist mächtig aber braucht sorgfältiges State Management** — Race Conditions sind real wenn mehrere Clients gleichzeitig interagieren.

2. **TypeScript spart Debugging-Zeit** — Besonders bei komplexen Spielzustand-Objekten. Der Compiler fängt so viele Fehler ab.

3. **Inkrementelles Speichern ist wichtig** — Warte nicht bis der User fertig ist um zu speichern. Speichere nach jeder Aktion.

4. **Dark Mode zuerst** — Wir haben 2024. Dark Mode als Standard. Die Augen deiner User werden es dir danken.

5. **Multiplayer macht süchtig** — Meine Freunde und ich duellieren uns viel mehr als wir sollten. Ist das Lernen? Technisch gesehen ja.

---

## War es das wert?

**Absolut.**

Habe ich mehr Zeit mit dem Bauen verbracht als ich mit normalem Lernen verbracht hätte? Wahrscheinlich.

Aber jetzt habe ich:
- Ein Tool das ich tatsächlich *benutzen will*
- Besseres Verständnis des Stoffs (vom Schreiben all der Erklärungen)
- Eine spaßige Art mit Freunden zu lernen
- Ein weiteres Projekt fürs Portfolio
- Diesen Blogpost

Und ehrlich? Die Duelle machen echt Spaß. Nichts motiviert mehr zum Lernen als die Gefahr gegen deine Freunde zu verlieren.

---

## Probier es aus

Die App ist live unter **[learn.engels.wtf](https://learn.engels.wtf)**

Einfach einen Namen eingeben und loslegen. Kein Account nötig, Fortschritt wird automatisch gespeichert.

Quellcode: [github.com/engelswtf/learn-together](https://github.com/engelswtf/learn-together)

---

*So, wenn ihr mich entschuldigt, ich muss für eine Prüfung lernen. Oder vielleicht baue ich erst noch ein Feature ein...*
