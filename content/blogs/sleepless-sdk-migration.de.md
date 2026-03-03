---
title: "Von CLI zu SDK: Wie der interne Agent von Sleepless-OpenCode wirklich unsichtbar wurde"
date: 2025-01-12
draft: false
tags: ["opencode", "sdk", "agents", "automation", "typescript", "sleepless-opencode"]
categories: ["AI", "Technical"]
description: "Wie wir von Kommandozeilen-Ausführung zu programmatischen SDK-Aufrufen migriert haben, um einen internen Agenten vor der UI zu verstecken und ein kniffliges Architekturproblem in sleepless-opencode zu lösen."
---

Ich habe [sleepless-opencode](https://github.com/Luca-Pelzer/sleepless-opencode) gebaut, einen 24/7-KI-Agent-Daemon, der Coding-Tasks im Hintergrund verarbeitet. Stell es dir wie eine Task-Queue vor, bei der du Arbeit über Discord einreichst und ein KI-Agent sie ausführt, während du schläfst.

Der Daemon verwendet einen spezialisierten Agenten namens `sleepless-executor`, um Tasks auszuführen. Dieser Agent ist rein intern gedacht – er soll nicht für direkte Benutzerinteraktion verwendet werden. Benutzer sollten ihn niemals manuell aus dem Agent-Picker auswählen.

Aber es gab ein Problem: **Damit er mit der OpenCode CLI funktioniert, musste der Agent als `mode: primary` konfiguriert werden, was ihn in der UI sichtbar machte.**

Das war nervig. Jedes Mal, wenn Benutzer den Agent-Picker öffneten, sahen sie dieses interne Implementierungsdetail, das ihre Oberfläche zumüllte. Nicht ideal.

## Die Herausforderung: CLI-Limitierungen

Der Daemon startete OpenCode-Sessions ursprünglich über die CLI:

```bash
opencode run --agent sleepless-executor --session <id> -- "<prompt>"
```

Das funktionierte gut, aber die OpenCode CLI hat eine Einschränkung: **Sie erkennt nur Agenten im `primary`-Modus**. Agenten, die als `subagent` konfiguriert sind (die von der UI versteckt werden), funktionieren einfach nicht mit CLI-Aufrufen.

Wir steckten also fest:
- `mode: primary` verwenden → Agent funktioniert, erscheint aber in der UI ❌
- `mode: subagent` verwenden → Agent versteckt, aber CLI schlägt fehl ❌

Keine der Optionen war akzeptabel.

## Die Untersuchung: Wie machen es Plugins?

Ich begann zu recherchieren, wie andere OpenCode-Plugins Agenten programmatisch starten. Speziell schaute ich mir den Quellcode des [oh-my-opencode](https://github.com/opencode-ai/oh-my-opencode) Plugins an.

Da entdeckte ich das Geheimnis: **OpenCode hat ein offizielles SDK** (`@opencode-ai/sdk`), das direkten API-Zugriff auf Session-Management bietet und die CLI komplett umgeht.

Dem SDK sind Agent-Modi egal. Es kann jeden Agenten starten – primary oder subagent – weil es direkt mit OpenCodes internen APIs kommuniziert.

Perfekt! Das war genau das, was wir brauchten.

## Die Lösung: Das SDK nutzen

Ich migrierte den Daemon von CLI-basierter zu SDK-basierter Ausführung. So funktioniert es:

### 1. SDK-Server initialisieren

Beim Daemon-Start erstellen wir einen OpenCode SDK-Server:

```typescript
import { createOpencode, type OpencodeClient } from "@opencode-ai/sdk";

this.abortController = new AbortController();
const opencode = await createOpencode({
  signal: this.abortController.signal,
  timeout: 30000,
});
this.client = opencode.client;
this.server = opencode.server;

console.log(`OpenCode SDK server started at ${this.server.url}`);
```

### 2. Sessions programmatisch erstellen

Anstatt CLI-Prozesse zu spawnen, nutzen wir die `session.create()` API des SDK:

```typescript
const createResult = await client.session.create({
  body: {
    title: `Sleepless Task #${task.id}`,
  },
  query: { directory: workDir },
});

const sessionId = createResult.data.id;
```

### 3. Prompts an jeden Agenten senden

Hier ist die Magie: `session.prompt()` funktioniert mit **jedem Agenten**, unabhängig vom Modus:

```typescript
const promptResult = await client.session.prompt({
  path: { id: sessionId },
  body: {
    agent: "sleepless-executor",  // Funktioniert auch als subagent!
    parts: [{ type: "text", text: prompt }],
  },
  query: { directory: workDir },
});
```

### 4. Auf Fertigstellung warten

Wir pollen den Session-Status, bis er idle wird:

```typescript
while (Date.now() - startTime < timeoutMs) {
  await this.sleep(2000);
  
  const statusResult = await client.session.status({
    query: { directory: workDir },
  });
  
  if (statusResult.data?.[sessionId]?.type === "idle") {
    const messagesResult = await client.session.messages({
      path: { id: sessionId },
      query: { directory: workDir },
    });
    return extractOutputFromMessages(messagesResult.data);
  }
}
```

### 5. Agent-Konfiguration aktualisieren

Schließlich haben wir den Agent-Modus auf `subagent` geändert:

```yaml
---
description: Internal daemon worker - do not use directly
mode: subagent  # Geändert von 'primary'
model: anthropic/claude-sonnet-4-5
---
```

Fertig! Der Agent ist jetzt vor der UI versteckt, aber voll funktionsfähig.

## Die Vorteile

Diese Migration brachte uns mehrere Gewinne:

1. **Vor der UI versteckt**: `sleepless-executor` vermüllt den Agent-Picker nicht mehr
2. **Programmatische Kontrolle**: Voller API-Zugriff auf Session-Management
3. **Bessere Integration**: Direkte Kommunikation ohne CLI-Overhead
4. **Abwärtskompatibel**: Fallback auf CLI, wenn SDK-Initialisierung fehlschlägt
5. **Sauberere Architektur**: Keine Shell-Prozesse mehr spawnen und stdout parsen

## Technischer Deep Dive

Das SDK bietet diese wichtigen APIs:

| API | Zweck |
|-----|-------|
| `session.create()` | Neue Agent-Sessions erstellen |
| `session.prompt()` | Prompts an Sessions senden (funktioniert mit jedem Agent-Modus) |
| `session.status()` | Prüfen ob Session idle/aktiv ist |
| `session.messages()` | Session-Nachrichten und Output abrufen |

Der Ausführungsfluss des Daemons sieht jetzt so aus:

```
1. Daemon startet → SDK-Server initialisieren
2. Task in Queue → Session via SDK erstellen
3. Prompt senden → session.prompt() mit Agent-Name
4. Status pollen → Warten bis session.status() === "idle"
5. Output extrahieren → session.messages() für Ergebnisse
6. Benutzer benachrichtigen → Discord/Slack-Nachricht senden
```

## Gelernte Lektionen

1. **Plugin-Quellcode lesen**: Wenn die Dokumentation deinen Use Case nicht abdeckt, tauche ein, wie bestehende Plugins ähnliche Probleme lösen.

2. **SDK > CLI für programmatische Nutzung**: Wenn du Automatisierung oder Integrationen baust, gibt dir das SDK viel mehr Kontrolle und Flexibilität als Shell-Aufrufe zur CLI.

3. **Agent-Modi sind wichtig**: Den Unterschied zwischen `primary` (benutzerorientiert) und `subagent` (intern) zu verstehen, ist entscheidend für saubere UIs.

4. **Immer einen Fallback haben**: Den CLI-Ausführungspfad als Fallback zu behalten, gewährleistet Robustheit, selbst wenn das SDK Probleme hat.

## Fazit

Diese Migration demonstriert die Mächtigkeit von OpenCodes SDK zum Bauen programmatischer Integrationen. Durch den Wechsel von CLI zu SDK haben wir eine sauberere Architektur erreicht, bei der interne Agenten versteckt bleiben können, während sie trotzdem voll funktionsfähig sind.

Wenn du OpenCode-Integrationen baust und programmatische Agent-Kontrolle brauchst, überspring die CLI und geh direkt zum SDK. Dein zukünftiges Ich (und deine Benutzer) werden es dir danken.

---

**Willst du sleepless-opencode ausprobieren?**

Schau es dir auf [GitHub](https://github.com/Luca-Pelzer/sleepless-opencode) an.
