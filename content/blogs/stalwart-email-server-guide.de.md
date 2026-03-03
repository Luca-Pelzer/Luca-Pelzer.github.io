---
title: "Mein eigener E-Mail-Server mit Stalwart: Eine Reise zu 10/10 (außer Microsoft)"
date: 2025-12-11
draft: false
tags: ["email", "stalwart", "self-hosting", "proxmox", "lxc", "dns", "smtp", "homelab"]
categories: ["Self-Hosting", "Homelab", "Tutorials"]
description: "Eine vollständige Anleitung zur Einrichtung eines selbst gehosteten E-Mail-Servers mit Stalwart Mail Server, Snappymail Webmail und allen benötigten DNS-Einträgen. Plus die laufende Saga von Microsoft, die meinen perfekt konfigurierten Server blockiert."
---

# Mein eigener E-Mail-Server mit Stalwart: Eine Reise zu 10/10 (außer Microsoft)

**Zusammenfassung**: Ich habe viel Zeit damit verbracht, meinen eigenen Mailserver mit Stalwart in einem LXC-Container auf Proxmox einzurichten. Ich habe einen perfekten 10/10-Score auf mail-tester.com erreicht, alle großen Provider akzeptieren meine E-Mails... außer Microsoft, die entschieden haben, dass meine Hetzner-IP schuldig durch Assoziation ist.

---

## Warum 2025 einen eigenen Mailserver betreiben?

Fangen wir mit der Wahrheit an: Einen eigenen Mailserver im Jahr 2025 zu betreiben gilt weithin als schlechte Idee. Gmail und Outlook sind kostenlos, zuverlässig und "funktionieren einfach."

Warum habe ich es trotzdem gemacht?

1. **Lernen** - Ich wollte E-Mail-Infrastruktur von Grund auf verstehen
2. **Kontrolle** - Meine E-Mails, mein Server, meine Regeln
3. **Berufserfahrung** - E-Mail-Server sind überall in Unternehmensumgebungen
4. **Weil ich es kann** - Ich habe ein Proxmox-Homelab und eine Domain

> ⚠️ **Realitätscheck**: Wenn du einfach nur E-Mails willst, die funktionieren, nutze Fastmail, Migadu oder ProtonMail.

## Voraussetzungen

### Hardware
- Server mit statischer öffentlicher IP (Hetzner Dedicated Server mit Proxmox VE)
- Mindestens 1GB RAM (ich habe 2GB vergeben)
- Speicher für E-Mails (32GB zum Start)

### Software/Dienste
- **Domainname** mit DNS-Kontrolle
- **Reverse DNS** Möglichkeit
- **LXC oder VM** Möglichkeit
- **Grundlegende Linux-Kenntnisse**

---

## Teil 1: Den LXC-Container einrichten

```bash
VMID: 107
Hostname: mail.engels.wtf
Template: Debian 12 (bookworm)
Kerne: 2
RAM: 2048 MB
Speicher: 32 GB
Netzwerk: 10.10.10.107/24 (intern)
```

### Stalwart installieren

```bash
apt update && apt upgrade -y
curl -sSL https://get.stalw.art | sh
```

> 💡 **Wichtig**: Stalwart speichert die meiste Konfiguration in seiner Datenbank, nicht in config.toml.

---

## Teil 2: Firewall-Konfiguration (Shorewall)

```bash
DNAT    net     loc:10.10.10.107:25     tcp     25      -       49.12.126.61
DNAT    net     loc:10.10.10.107:587    tcp     587     -       49.12.126.61
DNAT    net     loc:10.10.10.107:465    tcp     465     -       49.12.126.61
DNAT    net     loc:10.10.10.107:993    tcp     993     -       49.12.126.61
```

---

## Teil 3: Die DNS-Konfiguration

| Typ | Name | Wert |
|-----|------|------|
| A | mail | 49.12.126.61 |
| MX | @ | 10 mail.engels.wtf |
| TXT | @ | v=spf1 mx a:mail.engels.wtf -all |
| TXT | _dmarc | v=DMARC1; p=reject; rua=mailto:postmaster@engels.wtf |
| PTR | 49.12.126.61 | mail.engels.wtf |

> ⚠️ **Wichtig**: Erstelle einen postmaster@engels.wtf Account!

---

## Teil 4: Webmail hinzufügen (Snappymail)

```bash
apt install nginx php8.2-fpm php8.2-curl php8.2-xml php8.2-zip -y
```

> ⚠️ **Kritische Stolperfalle**: In der Snappymail-Domain-Config muss "type": 1 ein INTEGER sein, kein String "1"!

---

## Teil 5: Tests & Sieg (Fast)

### Mail-Tester Ergebnis: 10/10 🎉

- ✅ Gmail - Zugestellt
- ✅ ProtonMail - Zugestellt
- ❌ Outlook.com/Hotmail - **ABGELEHNT**

---

## Teil 6: Die Microsoft-Saga

```
550 5.7.1 Service unavailable; Client host [49.12.126.61] blocked using S3140
```

Microsoft blockiert ganze Hetzner-IP-Bereiche präventiv.

### Aktueller Status
- Gmail, ProtonMail: ✅ Funktioniert
- Microsoft: ❌ Immer noch blockiert

---

## Teil 7: Fehler, die ich gemacht habe

1. **Zu denken, config.toml sei alles** - Stalwart nutzt eine Datenbank
2. **Snappymail JSON-Typ-Fehler** - Integer vs String kostete mich eine Stunde
3. **postmaster@ vergessen** - Per RFC erforderlich
4. **Zu erwarten, dass Microsoft vernünftig ist** - Erwarte keine Logik

---

## Fazit: War es das wert?

### Das Gute ✅
- 10/10 mail-tester Score
- Volle Kontrolle
- Tiefes Lernen
- Funktioniert mit 95% der Provider

### Das Schlechte ❌
- Microsoft blockiert mich
- Wartungsverantwortung
- Komplexität

**Würde ich es nochmal machen?** Ja, aber nur weil ich das Basteln genieße.

---

## Ressourcen

- [Stalwart-Dokumentation](https://stalw.art/docs)
- [Snappymail](https://snappymail.eu/)
- [Mail-tester](https://mail-tester.com)
- [MXToolbox](https://mxtoolbox.com)

---

Fragen? Melde dich unter luca@engels.wtf (ja, es funktioniert... meistens).

**Update 2025-12-11**: Immer noch von Microsoft blockiert. Die Saga geht weiter.
