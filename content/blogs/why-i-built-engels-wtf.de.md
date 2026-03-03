---
title: "Warum ich engels.wtf gebaut habe: Mehr als nur ein weiterer Tech-Blog"
date: 2025-12-10
draft: false
tags: ["meta", "blogging", "homelab", "self-hosting", "hugo", "dokumentation"]
categories: ["Meta", "Homelab"]
description: "Warum ich meinen eigenen Blog von Grund auf gebaut habe, wie er in meinem Homelab läuft und warum Bloggen das beste Wissensmanagementsystem ist, das ich gefunden habe."
---

# Warum ich engels.wtf gebaut habe: Mehr als nur ein weiterer Tech-Blog

**TL;DR**: Ich habe meinen eigenen Blog mit Hugo gebaut, der in einem LXC-Container auf Proxmox läuft, mit Flatnotes als Schreib-Companion. Es geht nicht nur darum, Wissen zu teilen—es geht darum, eine persönliche Wissensdatenbank aufzubauen, die tatsächlich im Gehirn hängen bleibt.

---

## Das Problem: "Moment, wie habe ich das nochmal gelöst?"

Kennst du das Gefühl, wenn du um 2 Uhr morgens ein kniffliges Problem löst, dich wie ein Genie fühlst, und dann drei Monate später genau das gleiche Problem hast und absolut keine Ahnung mehr, was du gemacht hast?

Ja, ich auch. Viel zu oft.

Ich bastle schon eine Weile an meinem Homelab—Container aufsetzen, Dinge kaputtmachen, sie reparieren, wieder kaputtmachen. Ich löse etwas, denke "ach, das merke ich mir schon", und vergesse dann prompt alles außer dass es schmerzhaft war.

Ich habe versucht, Notizen in zufälligen Textdateien zu führen. Ich habe versucht, Lösungen zu bookmarken. Ich habe sogar versucht, meine eigenen Stack Overflow Fragen zu googeln (ja, das habe ich gemacht). Nichts ist hängen geblieben.

Dann wurde mir klar: **Ich muss darüber schreiben, als würde ich es jemandem erklären.**

## Warum Bloggen eigentlich eine Superkraft ist

Hier ist, was ich über das Schreiben von Blog-Posts versus "Notizen machen" gelernt habe:

### 1. **Schreiben lehrt dich doppelt**

Wenn du einen Blog-Post schreibst, kannst du nicht einfach Befehle in eine Datei werfen. Du musst:
- Erklären *warum* du etwas tust
- Kontext für dein zukünftiges Ich (oder andere) bieten
- Die Logik Schritt für Schritt durchdenken
- Lücken füllen, von denen du nicht wusstest, dass du sie hattest

Ich habe aufgehört zu zählen, wie oft ich dachte, ich verstehe etwas, anfange darüber zu schreiben und mir klar wird "warte, warum funktioniert das?" Dann passiert das echte Lernen.

### 2. **Dein zukünftiges Ich wird dir danken**

In sechs Monaten, wenn mein Mailserver Probleme hat (seien wir ehrlich, er wird), werde ich mich nicht an den genauen DKIM-Selektor erinnern, den ich benutzt habe, oder wo ich diesen DNS-Record hingelegt habe. Aber ich werde einen Blog-Post mit dem Titel "Stalwart Mail Server einrichten" haben, mit jedem Detail dokumentiert.

**Vergangenheits-Ich hilft Zukunfts-Ich.** Es ist, als würdest du dir selbst Versorgungspakete für die Zukunft hinterlassen.

### 3. **Du hilfst anderen (und das fühlt sich gut an)**

Die Anzahl der Male, die ich durch den zufälligen Blog-Post von jemandem aus 2015 gerettet wurde, ist absurd. Irgendeine Person, die ich nie treffen werde, hat genau das Problem gelöst, das ich hatte, und es dokumentiert.

Jetzt kann ich es zurückgeben. Und ehrlich? Es fühlt sich ziemlich gut an zu wissen, dass meine 2-Uhr-morgens-Debugging-Session vielleicht die 2-Uhr-morgens-Debugging-Session von jemand anderem rettet.

### 4. **Verantwortlichkeit hält die Dinge sauber**

Wenn du weißt, dass du möglicherweise öffentlich über etwas schreibst, neigst du dazu, es richtig zu machen. Keine "temporären" Fixes mehr, die permanent werden. Kein "ich räume das später auf" mehr (Erzähler: er hat es später nicht aufgeräumt).

Über mein Setup zu schreiben zwingt mich, meine Infrastruktur tatsächlich richtig zu verstehen und zu dokumentieren.

---

## Das technische Setup: Wie dieser Blog tatsächlich funktioniert

Gut, genug Philosophie. Sprechen wir darüber, wie dieser Blog tatsächlich gebaut ist.

### Der Stack

- **Static Site Generator**: Hugo (schnell, einfach, und keine PHP-Sicherheitslücken)
- **Theme**: Hugo Noir (clean, minimal, schnell)
- **Hosting**: LXC-Container (ID: 106) auf meinem Proxmox-Server
- **Reverse Proxy**: Caddy (auf LXC 104) kümmert sich um SSL und Routing
- **Schreibumgebung**: Flatnotes (eine selbst gehostete Note-Taking-App)
- **Mehrsprachig**: Eingebaute Unterstützung für Englisch, Deutsch und Spanisch

### Architektur-Übersicht

```
Internet
    ↓
Cloudflare (DNS + CDN)
    ↓
Caddy Proxy (LXC 104, 10.10.20.10)
    ↓
Hugo Server (LXC 106, 10.10.20.106:1313)
```

### Warum LXC statt Docker?

Ich weiß, ich weiß—jeder benutzt Docker für alles. Aber die Sache ist: **LXC-Container sind perfekt für lange laufende Services wie diesen.**

- Leichtgewichtig (1GB RAM, 2 CPU-Kerne, 8GB Speicher)
- Fühlt sich an wie eine echte VM, nutzt aber viel weniger Ressourcen
- Einfach zu snapshotten und zu backuppen in Proxmox
- Kein Docker-Overhead für eine einzelne Anwendung
- Kann trotzdem Docker darin nutzen, wenn ich will (tue ich für Flatnotes)

### Der Hugo-Server-Service

Ich habe Hugo so eingerichtet, dass es als systemd-Service läuft und automatisch beim Booten startet:

```bash
[Unit]
Description=Hugo Server for Engels Blog
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=/var/www/engels-blog
ExecStart=/usr/local/bin/hugo server \
  --bind 0.0.0.0 \
  --port 1313 \
  --baseURL https://www.engels.wtf \
  --appendPort=false \
  --environment production \
  --disableLiveReload
Restart=always

[Install]
WantedBy=multi-user.target
```

Hugos eingebauter Server ist überraschend robust für den Produktivbetrieb. Er serviert statische Dateien schnell, handhabt das mehrsprachige Routing und baut automatisch neu, wenn ich neuen Content hinzufüge.

> 💡 **Tipp**: Ich dachte früher, man bräuchte nginx oder Apache vor Hugo. Nö. Caddy Reverse Proxy + Hugo Server = völlig ausreichend für einen persönlichen Blog.

### Caddy: Der beste Reverse Proxy, den du nicht benutzt

Meine Caddy-Konfiguration für den Blog ist wunderbar einfach:

```caddy
www.engels.wtf {
    header {
        X-Content-Type-Options "nosniff"
        X-Frame-Options "SAMEORIGIN"
        X-XSS-Protection "1; mode=block"
        Referrer-Policy "strict-origin-when-cross-origin"
        -Server
    }
    
    reverse_proxy 10.10.20.106:1313
}

engels.wtf {
    redir https://www.engels.wtf{uri} permanent
}
```

Das war's. Caddy kümmert sich um:
- ✅ Automatische SSL-Zertifikate von Let's Encrypt
- ✅ HTTP zu HTTPS Redirect
- ✅ Apex zu www Redirect
- ✅ Security-Header
- ✅ Reverse Proxying zum Hugo-Container

Keine kryptischen nginx-Configs. Keine 3 Stunden damit verbringen, SSL-Zertifikate zu debuggen. Es funktioniert einfach.

### Die Geheimwaffe: Flatnotes

Hier wird's interessant. Ich lasse [Flatnotes](https://github.com/dullage/flatnotes) in einem Docker-Container auf dem gleichen LXC wie Hugo laufen:

```
notes.engels.wtf → Passwortgeschütztes Flatnotes-Interface
                 → Schreibt direkt nach /var/www/engels-blog/content/blogs/
                 → Hugo baut automatisch neu, wenn es neue Dateien erkennt
```

Das bedeutet, ich kann:
1. notes.engels.wtf auf jedem Gerät öffnen
2. Einen Blog-Post in Markdown schreiben
3. Speichern
4. Hugo erkennt automatisch die neue Datei und baut neu
5. Neuer Post ist innerhalb von Sekunden live

**Keine Git-Commits. Kein SSH auf den Server. Keine Build-Pipelines.** Einfach schreiben und speichern.

> ⚠️ **Sicherheitshinweis**: Flatnotes ist hinter Basic Authentication. Stelle nie Note-Taking-Apps ohne Authentifizierung bereit!

---

## Mehrsprachigkeit: Warum nicht?

Eine Sache, die ich von Anfang an wollte, war Mehrsprachigkeitsunterstützung. Meine Konfiguration unterstützt:
- 🇬🇧 Englisch (primär)
- 🇩🇪 Deutsch (meine Muttersprache)
- 🇪🇸 Spanisch (zum Üben und für größere Reichweite)

Hugo macht das überraschend einfach. Jeder Blog-Post kann Sprachvarianten haben:
- `post.md` (Englisch)
- `post.de.md` (Deutsch)
- `post.es.md` (Spanisch)

Das Theme generiert automatisch Sprachumschalter, und Nutzer bekommen die richtige Version basierend auf ihrer Browser-Sprache.

Schreibe ich alles in allen drei Sprachen? Nicht immer. Aber die Infrastruktur zu haben bedeutet, dass ich es kann, wenn es Sinn macht.

---

## Was ich beim Bau gelernt habe

### Fehler, die ich gemacht habe

**1. Die Infrastruktur überkompliziert**

Ich hatte ursprünglich eine ganze CI/CD-Pipeline mit Git-Webhooks und automatisierten Deployments geplant. Dann wurde mir klar: das ist ein persönlicher Blog, keine Unternehmensanwendung. Hugos eingebautes File-Watching + Flatnotes = völlig ausreichend.

**2. Zu lange mit dem Design verbracht**

Ich habe Stunden damit verschwendet, CSS zu tweaken, bevor ich irgendwelchen Content hatte. Stellt sich heraus, niemanden interessiert dein perfektes Farbschema, wenn es nichts zu lesen gibt. Content first, Feinschliff später.

**3. Vergessen, Backups einzurichten**

Ja, ich ließ den Blog ein paar Stunden laufen, bevor mir klar wurde "warte, ich sollte das wahrscheinlich backuppen." Jetzt habe ich täglich geplante Proxmox-Snapshots.

### Was ich anders machen würde

- **Mit einem einfachen Theme starten**: Hugo Noir ist großartig, aber ich habe zu lange Themes verglichen. Wähle etwas Cleanes und mach weiter.
- **Mehr schreiben, früher veröffentlichen**: Perfektionismus tötet Blogs. Fertig ist besser als perfekt.
- **Analytics von Tag eins einrichten**: Ich habe das später hinzugefügt und jetzt fehlen mir frühe Daten (nicht dass es viel Traffic gab).

---

## Der Blog als Wissensmanagementsystem

Hier ist der echte Grund, warum das alles existiert: **mein Gehirn ist unzuverlässig.**

Ich kann mich nicht an die spezifische Shorewall-Regel erinnern, die ich zum Erlauben von SMTP brauche, aber ich kann mich erinnern "oh ja, darüber habe ich beim Mail-Server-Setup geschrieben."

Ich kann mich nicht an die genauen LVM-Befehle zum Erweitern eines Logical Volumes erinnern, aber ich kann meinen eigenen Blog nach "LVM" durchsuchen.

Dieser Blog ist nicht nur für andere—**er ist mein externes Gehirn.**

Jedes Mal, wenn ich ein Problem löse, schreibe ich darüber. Jedes Mal, wenn ich etwas Neues einrichte, dokumentiere ich es. Jedes Mal, wenn ich einen Fehler mache (was oft vorkommt), notiere ich, was schief ging und wie ich es behoben habe.

In sechs Monaten, wenn ich unweigerlich etwas tun muss, was ich schon mal gemacht habe, werde ich nicht bei Null anfangen. Ich werde Schritt-für-Schritt-Dokumentation haben, geschrieben von jemandem, der tatsächlich den Prozess durchlaufen hat—Vergangenheits-Ich.

---

## Was kommt als Nächstes?

Jetzt, wo die Infrastruktur läuft, beginnt die echte Arbeit: tatsächlich regelmäßig schreiben.

Posts, die ich plane:
- **Stalwart Mail Server einrichten** (weil ich das gerade heute gemacht habe und es ein Abenteuer war)
- **Proxmox Network Tuning** (das IRQ-Problem beheben, das meinen Server verlangsamt hat)
- **n8n für Automation selbst hosten** (mein Workflow-Automatisierungs-Setup)
- **Einen mehrsprachigen Hugo-Blog bauen** (meta, aber nützlich für andere)

## Willst du deinen eigenen bauen?

Das ganze Setup ist ziemlich unkompliziert. Wenn du einen Proxmox-Server hast (oder irgendeine Linux-Box), kannst du das an einem Nachmittag nachbauen:

1. LXC-Container erstellen
2. Hugo installieren
3. Theme auswählen
4. Caddy als Reverse Proxy konfigurieren
5. (Optional) Flatnotes für einfaches Editieren hinzufügen
6. Anfangen zu schreiben

Der schwierigste Teil ist nicht das technische Setup—es ist tatsächlich hinzusetzen und zu schreiben. Aber das ist ein Problem, das keine Menge Infrastruktur lösen kann.

---

## Schlusswort

Diesen Blog zu bauen hat vielleicht 4 Stunden tatsächliche Arbeit gekostet. Das meiste davon war Konfigurationen tweaken und Flatnotes einrichten.

Aber der Wert? Unbezahlbar.

Jeder Post, den ich schreibe, ist eine Investition in die geistige Gesundheit meines zukünftigen Ichs. Jedes Tutorial, das ich dokumentiere, ist ein Problem weniger, das ich zweimal lösen muss. Jeder Fehler, den ich festhalte, ist eine Lektion, die ich nicht neu lernen muss.

Wenn du mit Homelabs, Self-Hosting oder Infrastruktur herumbastelst, **fang an zu dokumentieren.** Dein zukünftiges Ich wird dir danken. Und wer weiß—vielleicht hilfst du jemandem, genau das Problem zu lösen, bei dem er um 2 Uhr morgens feststeckt.

Deshalb existiert `engels.wtf`. Nicht nur als Blog, sondern als lebende Wissensdatenbank, die jedes Mal wächst, wenn ich etwas Neues lerne.

Wenn du mich jetzt entschuldigst, ich habe etwa 47 andere Dinge, über die ich wahrscheinlich schreiben sollte, bevor ich sie vergesse.
