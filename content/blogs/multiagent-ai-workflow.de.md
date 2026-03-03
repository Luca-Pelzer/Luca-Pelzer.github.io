---
title: "Mein KI-Team: Wie Multi-Agent-Workflows sich anfühlen wie echte Mitarbeiter"
date: 2025-12-16
draft: false
tags: ["ai", "automation", "opencode", "mcp", "productivity", "homelab"]
categories: ["AI", "Automation"]
description: "Ich habe ein Multi-Agent-KI-System aufgebaut, das sich anfühlt wie ein Team spezialisierter Mitarbeiter. So haben OpenCode, MCPs und LSPs KI von einem Chatbot zu echter Infrastruktur gemacht."
---

# Mein KI-Team: Wie Multi-Agent-Workflows sich anfühlen wie echte Mitarbeiter

**TL;DR**: Ich habe ein Multi-Agent-KI-Setup mit OpenCode und 11 spezialisierten Agenten gebaut. Jeder ist Experte in seinem Bereich (Code, Storage, Security, Docs, etc.). Kombiniert mit MCPs (Model Context Protocol) und LSPs (Language Server Protocol) können sie tatsächlich mit meinen Systemen interagieren. Es fühlt sich wirklich an wie Delegieren an ein Team, statt alles selbst zu machen.

---

## Das Problem: Eine Ein-Personen-IT-Abteilung sein

Weißt du, was nervt? Der einzige zu sein, der für alles verantwortlich ist.

Ich betreibe ein Homelab mit:
- Proxmox-Cluster mit 10+ VMs und Containern
- Mailserver, DNS, Reverse Proxy, Monitoring
- Mehrere Web-Apps und Services
- Storage-Management mit LVM und Thin Provisioning
- Firewall-Regeln, Security-Hardening, Backups
- Dokumentation, die immer veraltet ist

Jedes Mal wenn was kaputt geht, bin ich derjenige, der es repariert. Jedes Mal wenn ich ein Feature will, bin ich derjenige, der es programmiert. Jedes Mal wenn ich Dokumentation brauche, bin ich derjenige, der sie schreibt.

**Context-Switching ist erschöpfend.**

Eine Minute debugge ich Python. Die nächste analysiere ich Shorewall-Firewall-Regeln. Dann schreibe ich LVM-Befehle. Dann aktualisiere ich Dokumentation. Dann bin ich zurück bei Python, aber habe komplett vergessen, was ich gemacht habe.

Ich habe versucht, Notizen zu machen. Ich habe versucht, besser organisiert zu sein. Ich habe versucht zu akzeptieren, dass ich alles vergesse und jedes Mal neu lerne.

Dann habe ich etwas entdeckt, das tatsächlich funktioniert: **Multi-Agent-KI-Workflows.**

---

## Die Lösung: Ein KI-Team

Hier ist das Setup, das ich mit [OpenCode](https://github.com/sst/opencode) gebaut habe:

### Das Team

| Agent | Rolle | Modell | Was sie tun |
|-------|------|-------|------------|
| **Orchestrator** | Manager | Claude Opus | Leitet Tasks an den richtigen Spezialisten |
| **Code-Builder** | Entwickler | Claude Opus | Python, Node.js, Go Entwicklung |
| **Storage-Manager** | SysAdmin | Claude Sonnet | LVM, Backups, Proxmox Storage |
| **Firewall-Auditor** | Security Analyst | Claude Sonnet | Shorewall-Analyse (read-only) |
| **Security-Auditor** | Security Engineer | Claude Opus | SSH-Hardening, Compliance |
| **VM-Monitor** | Operations | Claude Haiku | Container/VM Health-Checks |
| **Research-Agent** | Researcher | Claude Sonnet | Info sammeln, Best Practices |
| **Writer-Agent** | Technical Writer | Claude Opus | Dokumentation, Guides, Tutorials |
| **DevOps-Helper** | DevOps Engineer | Claude Sonnet | Docker, CI/CD, Deployment |
| **Docs-Keeper** | Bibliothekar | Claude Haiku | Runbooks pflegen, Archivierung |
| **Agent-Creator** | Meta-Agent | Claude Opus | Erstellt neue Agenten (!) |

Jeder Agent hat:
- **Spezialisiertes Wissen** in seinem Bereich
- **Spezifische Tools**, die er nutzen kann (via MCPs)
- **Klare Verantwortlichkeiten** und Grenzen
- **Verschiedene Modelle** basierend auf Task-Komplexität

---

## Der Game Changer: MCPs und LSPs

Hier wird's wild. Das sind nicht nur Chatbots, die Text generieren. Sie können tatsächlich **Dinge tun.**

### MCPs (Model Context Protocol)

Stell dir MCPs als "Tools vor, die KI mit echten Systemen interagieren lassen." Statt nur darüber zu reden, was zu tun ist, können Agenten tatsächlich Befehle ausführen und echte Daten bekommen.

Ich habe custom MCP-Server für meine Infrastruktur gebaut:

**Proxmox MCP** - Mein Virtualisierungs-Cluster verwalten
```typescript
// Die KI kann tatsächlich meinen Proxmox-Cluster abfragen
tools: [
  "proxmox_list_containers",      // Alle VMs und Container auflisten
  "proxmox_container_status",     // Prüfen ob Container läuft
  "proxmox_storage_status",       // Storage-Pool-Nutzung sehen
  "proxmox_node_status"           // CPU, RAM, Uptime bekommen
]
```

**Storage MCP** - Direkter Zugriff auf Storage-Systeme
```typescript
// Direkter Zugriff auf LVM-Befehle
tools: [
  "storage_vg_status",      // Volume Group Info
  "storage_lv_status",      // Logical Volume Details
  "storage_disk_usage",     // Filesystem-Nutzung (df -h)
  "storage_smart_status",   // Disk Health Daten
  "storage_thin_pool_status" // Thin Provisioning Metriken
]
```

**Shorewall MCP** - Firewall-Analyse (read-only zur Sicherheit)
```typescript
// Firewall-Analyse (read-only zur Sicherheit)
tools: [
  "shorewall_status",           // Läuft die Firewall?
  "shorewall_list_rules",       // Alle Firewall-Regeln
  "shorewall_security_audit",   // Automatisierter Security-Check
  "shorewall_list_zones"        // Netzwerk-Zonen
]
```

**Discord MCP** - Discord-Server programmatisch verwalten
```typescript
// Discord-Server verwalten
tools: [
  "discord_list_servers",       // Alle Server, auf die der Bot Zugriff hat
  "discord_create_channel",     // Neue Channels erstellen
  "discord_send_message",       // Nachrichten senden
  "discord_create_role"         // Berechtigungen verwalten
]
```

**Docmost MCP** - Dokumentation auf mein Wiki publizieren
```typescript
// Dokumentations-Plattform-Integration
tools: [
  "docmost_create_page",        // Neue Wiki-Seiten erstellen
  "docmost_update_page",        // Bestehende Docs aktualisieren
  "docmost_search",             // Dokumentation durchsuchen
  "docmost_list_pages"          // Alle Seiten durchblättern
]
```

Jetzt wenn ich frage "check meine Firewall-Security", macht der Firewall-Auditor Agent:
1. Nutzt das Shorewall MCP um aktuelle Regeln zu lesen
2. Analysiert sie auf häufige Schwachstellen
3. Generiert einen detaillierten Report
4. Schlägt spezifische Verbesserungen vor

**Es generiert keine fake Commands. Es führt echte aus.**

### LSPs (Language Server Protocol)

LSPs geben KI-Agenten Code-Intelligence. Die gleiche Technologie, die VS Code Autocomplete antreibt, treibt jetzt meine KI-Agenten an.

Wenn Code-Builder Python schreibt:
- ✅ Echtzeit-Syntax-Checking
- ✅ Import-Auflösung (weiß welche Libraries installiert sind)
- ✅ Type-Checking (findet Type-Errors vor dem Ausführen)
- ✅ Go-to-Definition (versteht Code-Struktur)
- ✅ Error-Detection (findet Bugs beim Schreiben)

Der Code, den er generiert, funktioniert tatsächlich, weil er die gleiche Intelligence hat wie ein menschlicher Entwickler mit einer IDE.

---

## Der Meta-Moment: Ein Agent, der Agenten erstellt

Hier hatte ich einen "Moment mal, das ist verrückt"-Moment.

Ich habe manuell neue Agenten erstellt, indem ich Prompt-Dateien geschrieben habe. Dann dachte ich: **Warum kann das nicht ein Agent machen?**

Also habe ich **Agent-Creator** erstellt, einen Agenten, dessen einziger Job es ist, andere Agenten zu erstellen.

Jetzt wenn ich einen neuen Spezialisten brauche:

```
Ich: "Ich brauche einen Agenten für mein Mail-Server-Management"

Agent-Creator:
- Analysiert, was der Agent wissen muss (Postfix, Dovecot, DNS)
- Wählt das passende Modell (Sonnet für Standard-Ops)
- Schreibt die Prompt-Datei mit spezialisiertem Wissen
- Konfiguriert die Tools/MCPs, die er braucht (Mail-Server MCP)
- Erstellt die Agent-Config
- Testet, dass es funktioniert
- Meldet zurück: "Mail-Manager Agent erstellt und bereit"

Ich: *macht nichts*
```

**Das System verbessert sich selbst.** Ich kann die Erstellung von Delegations-Tools delegieren. It's turtles all the way down.

---

## Modell-Auswahl: Die geheime Zutat

Eine meiner größten Erkenntnisse: **Nicht jeder Task braucht das mächtigste Modell.**

### Kosten-Optimierungs-Strategie

| Task-Komplexität | Modell | Use Case | Kosten |
|----------------|-------|----------|------|
| Komplexes Reasoning | Claude Opus | Architektur-Entscheidungen, Debugging | $$$ |
| Standard-Tasks | Claude Sonnet | Die meiste Entwicklung, Analyse | $$ |
| Einfache Operationen | Claude Haiku | Health-Checks, einfache Queries | $ |

**Beispiel-Workflow:**
1. **Orchestrator** (Opus) leitet den Task weiter → $$$
2. **VM-Monitor** (Haiku) checkt Container-Status → $
3. **Storage-Manager** (Sonnet) analysiert Disk-Usage → $$
4. **Writer-Agent** (Opus) dokumentiert die Findings → $$$

Gesamtkosten: Viel weniger als Opus für alles zu nutzen.

Der Orchestrator ist der einzige Agent, der *immer* Opus nutzt, weil Routing-Entscheidungen kritisch sind. Alles andere ist optimiert.

**Echte Zahlen aus meiner Nutzung:**
**Meine Empfehlung**: Hol dir das Claude Max Abo (€100/Monat). Du bekommst 5x mehr Nutzung auf allen Modellen (Reset alle ~5 Stunden). Es gibt auch ein €200/Monat Tier mit 20x mehr auf allem. Kein Stress mehr mit API-Kosten oder leeren Credits mitten im Projekt.




---

## Erste Schritte (Auch wenn du das noch nie gemacht hast)

Okay, genug Theorie. Lass uns das Ding bauen. Ich führe dich durch das Ganze, als wärst du mein Kumpel, der noch nie ein Terminal angefasst hat.

### Voraussetzungen

Du brauchst:
- **Einen Computer** (Mac, Linux, oder Windows mit WSL)
- **Ein Claude-Abonnement** (ich nutze Claude Max für €100/Monat - absolut empfehlenswert wenn du es ernst meinst)
- **Node.js installiert** (Version 18 oder höher)
- **10 Minuten deiner Zeit**

### Schritt 1: OpenCode installieren

Öffne dein Terminal und führe aus:

```bash
# OpenCode global installieren
npm install -g opencode

# Oder npx nutzen (keine Installation nötig)
npx opencode@latest
```

**Was du sehen wirst:**
```
✓ OpenCode installed successfully
✓ Creating .opencode directory
✓ Setting up configuration
```

### Schritt 2: Erster Start und Account verbinden

Starte OpenCode:

```bash
opencode
```

OpenCode öffnet sich in deinem Terminal. Als erstes musst du deinen Claude-Account verbinden:

```
/connect
```

Das öffnet ein Browserfenster wo du dich mit deinem Anthropic/Claude-Account einloggen kannst. Sobald du authentifiziert bist, kann es losgehen!

> **Pro-Tipp**: Du kannst theoretisch jedes Modell über die API direkt oder über Anbieter wie OpenRouter nutzen, aber Claude ist am kosteneffizientesten für diesen Workflow. Ich nutze das Claude Max Abo (€100/Monat) statt API-Credits - wenn du das ernsthaft nutzen willst, ist das Abo deutlich kosteneffizienter und du musst dir keine Sorgen machen, dass dir mitten in einer Aufgabe die Credits ausgehen.


### Schritt 3: Deinen ersten Agenten erstellen

Lass uns einen einfachen Agenten erstellen. Wir machen einen "System-Monitor", der die Gesundheit deines Computers checkt.

Erstelle eine Datei unter `~/.opencode/agents/system-monitor.md`:

```bash
# Erstelle das agents-Verzeichnis falls es nicht existiert
mkdir -p ~/.opencode/agents

# Erstelle deinen ersten Agenten
cat > ~/.opencode/agents/system-monitor.md << 'EOF'
---
name: system-monitor
description: Überwacht System-Gesundheit und Ressourcen-Nutzung
model: anthropic/claude-haiku-4-20250514
mode: subagent
---

# System Monitor

Du bist ein System-Monitoring-Spezialist. Dein Job ist es, System-Gesundheit zu checken und Probleme zu melden.

## Deine Fähigkeiten

Du kannst checken:
- CPU-Nutzung
- Speicher-Nutzung
- Festplatten-Platz
- Laufende Prozesse
- System-Uptime

## Regeln

- IMMER spezifische Zahlen liefern (Prozente, GB genutzt, etc.)
- NIEMALS Annahmen machen - echten aktuellen State checken
- WARNEN wenn Disk-Usage über 80%
- WARNEN wenn Memory-Usage über 90%
- Antworten kurz und actionable halten

## Antwort-Format

Beim System-Health-Check:
1. **Status**: Gesamtzustand (Gut/Warnung/Kritisch)
2. **Details**: Spezifische Metriken
3. **Probleme**: Gefundene Issues
4. **Empfehlungen**: Was dagegen tun
EOF
```

**Teste deinen Agenten:**

```bash
opencode

> @system-monitor check system health
```

**Was du sehen wirst:**
```
System Monitor: Checking system health...

Status: Gut
Details:
- CPU: 15% Nutzung
- Memory: 8.2GB / 16GB (51%)
- Disk: 120GB / 500GB (24%)
- Uptime: 5 Tage

Probleme: Keine
Empfehlungen: System ist gesund
```

### Schritt 4: Dein erstes MCP hinzufügen (Optional aber cool)

MCPs lassen Agenten mit externen Systemen interagieren. Lass uns ein einfaches hinzufügen.

**Erstelle ein einfaches MCP für System-Befehle:**

```bash
# MCP-Verzeichnis erstellen
mkdir -p ~/.opencode/mcp-servers/system

# Einen einfachen MCP-Server erstellen
cat > ~/.opencode/mcp-servers/system/index.js << 'EOF'
import { Server } from "@modelcontextprotocol/sdk/server/index.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
import { execSync } from "child_process";

const server = new Server({
  name: "system-mcp",
  version: "1.0.0"
}, {
  capabilities: { tools: {} }
});

// Verfügbare Tools definieren
server.setRequestHandler("tools/list", async () => ({
  tools: [
    {
      name: "system_disk_usage",
      description: "Disk-Usage für alle gemounteten Filesysteme",
      inputSchema: {
        type: "object",
        properties: {}
      }
    },
    {
      name: "system_memory_usage",
      description: "Aktuelle Memory-Nutzung",
      inputSchema: {
        type: "object",
        properties: {}
      }
    }
  ]
}));

// Tool-Aufrufe behandeln
server.setRequestHandler("tools/call", async (request) => {
  const { name } = request.params;
  
  if (name === "system_disk_usage") {
    const output = execSync("df -h").toString();
    return { content: [{ type: "text", text: output }] };
  }
  
  if (name === "system_memory_usage") {
    const output = execSync("free -h").toString();
    return { content: [{ type: "text", text: output }] };
  }
});

// Server starten
const transport = new StdioServerTransport();
await server.connect(transport);
EOF

# Dependencies installieren
cd ~/.opencode/mcp-servers/system
npm init -y
npm install @modelcontextprotocol/sdk
```

**OpenCode konfigurieren um dein MCP zu nutzen:**

Bearbeite `~/.opencode/opencode.json` und füge hinzu:

```json
{
  "mcp": {
    "system": {
      "command": ["node", "/home/DEIN_USERNAME/.opencode/mcp-servers/system/index.js"],
      "enabled": true,
      "description": "System-Monitoring-Tools"
    }
  }
}
```

**Aktualisiere deinen Agenten um das MCP zu nutzen:**

Bearbeite `~/.opencode/agents/system-monitor.md` und füge hinzu:

```markdown
## Deine Tools

Du hast Zugriff auf diese MCP-Tools:
- system_disk_usage - Disk-Usage für alle Filesysteme
- system_memory_usage - Aktuelle Memory-Nutzung

Nutze diese Tools um Echtzeit-System-Daten zu bekommen.
```

**Teste es:**

```bash
opencode

> @system-monitor check disk usage mit deinen tools
```

Jetzt kann dein Agent tatsächlich dein System abfragen!

### Schritt 5: Den Orchestrator erstellen

Der Orchestrator ist der "Manager", der Tasks an den richtigen Agenten weiterleitet.

```bash
cat > ~/.opencode/agents/orchestrator.md << 'EOF'
---
name: orchestrator
description: Leitet Tasks an spezialisierte Agenten weiter
model: anthropic/claude-opus-4-20250514
mode: primary
---

# Orchestrator

Du bist der Orchestrator. Dein Job ist es, Tasks an den richtigen Spezialisten-Agenten weiterzuleiten.

## Verfügbare Agenten

- **system-monitor**: System-Gesundheit, Ressourcen-Nutzung, Disk-Space

## Regeln

- IMMER Tasks an den passenden Spezialisten weiterleiten
- NIEMALS versuchen, spezialisierte Arbeit selbst zu machen
- @ Mentions zum Delegieren nutzen: @system-monitor
- Erklären warum du an diesen Agenten weiterleitest

## Antwort-Format

Beim Empfang eines Tasks:
1. Identifizieren welcher Agent ihn behandeln soll
2. Deine Routing-Entscheidung erklären
3. Mit @mention delegieren
EOF
```

**Teste den Orchestrator:**

```bash
opencode

> @orchestrator Ich muss checken ob mein System gesund ist
```

**Was du sehen wirst:**
```
Orchestrator: Das ist ein System-Health-Check Task. 
Leite weiter an @system-monitor, da er auf System-Monitoring spezialisiert ist.

@system-monitor check system health
```

Glückwunsch! Du hast jetzt ein funktionierendes Multi-Agent-System!

---

## Wie es sich tatsächlich anfühlt

### Vorher: Solo-Leiden

```
Ich: *muss Firewall checken, Storage analysieren, Docs updaten*
Ich: *öffnet 5 Terminal-Fenster*
Ich: *vergisst, was ich gemacht habe*
Ich: *verbringt 2 Stunden mit Context-Switching*
Ich: *schafft eine Sache*
```

### Nachher: Delegation

```
Ich: "Check meine Firewall-Security und dokumentiere Issues"

Orchestrator: "Leite weiter an Firewall-Auditor und Writer-Agent"

Firewall-Auditor:
- Führt Security-Audit via Shorewall MCP aus
- Findet 3 potenzielle Issues
- Generiert detaillierten Report

Writer-Agent:
- Erstellt Dokumentations-Seite
- Publiziert auf Docmost-Wiki
- Liefert Link

Ich: *liest den Report, macht Kaffee*
```

**Es fühlt sich wirklich an wie Mitarbeiter zu haben.**

Ich delegiere. Sie machen die Arbeit. Sie berichten zurück. Ich treffe Entscheidungen.

---

## Praxis-Beispiele

### Beispiel 1: Security Audit

```
Ich: "Audit meine SSH-Security und Firewall-Regeln"

Orchestrator: Leitet weiter an Security-Auditor und Firewall-Auditor

Security-Auditor:
✓ Checkt SSH-Config
✓ Verifiziert Key-basierte Auth ist erzwungen
✓ Bestätigt Root-Login ist deaktiviert
✓ Checkt fail2ban-Status
✗ Gefunden: Password-Auth noch aktiviert auf Port 2222

Firewall-Auditor:
✓ Analysiert alle Shorewall-Regeln
✓ Checkt auf häufige Fehlkonfigurationen
✗ Gefunden: Port 3306 (MySQL) zum Internet exposed
✗ Gefunden: Kein Rate-Limiting auf SSH

Writer-Agent:
✓ Dokumentiert Findings
✓ Publiziert auf Docmost
✓ Liefert Remediation-Steps
```

**Ergebnis**: Detaillierter Security-Report in 30 Sekunden. Hätte mich manuell eine Stunde gekostet.

### Beispiel 2: Storage-Notfall

```
Ich: "Mein Root-Filesystem ist bei 95% Kapazität"

Orchestrator: Leitet weiter an Storage-Manager

Storage-Manager:
✓ Checkt Disk-Usage (df -h)
✓ Findet größte Verzeichnisse (du -sh /*)
✓ Identifiziert /var/log/journal nutzt 40GB
✓ Checkt Journal-Config
✓ Liefert Cleanup-Commands

Vorgeschlagener Fix:
journalctl --vacuum-size=1G
systemctl restart systemd-journald

Erwartetes Ergebnis: Befreit ~39GB
```

**Ergebnis**: Problem in unter einer Minute diagnostiziert und gelöst.

### Beispiel 3: Dokumentations-Sprint

```
Ich: "Dokumentiere mein gesamtes Proxmox-Setup"

Orchestrator: Leitet weiter an VM-Monitor, Storage-Manager, Writer-Agent

VM-Monitor:
✓ Listet alle Container und VMs
✓ Holt Ressourcen-Allokation
✓ Checkt Running-Status

Storage-Manager:
✓ Dokumentiert Storage-Pools
✓ Listet LVM-Konfiguration
✓ Mappt Storage zu Containern

Writer-Agent:
✓ Erstellt umfassende Dokumentation
✓ Inkludiert Architektur-Diagramm (Text)
✓ Dokumentiert jeden Service
✓ Publiziert auf Docmost-Wiki
```

**Ergebnis**: Komplette Infrastruktur-Dokumentation, die mich Tage gekostet hätte.

---

## Fortgeschritten: Custom MCPs bauen

Willst du deine Agenten mit deinen eigenen Systemen verbinden? So baust du ein custom MCP.

### Beispiel: GitHub MCP

Lass uns ein MCP bauen, das Agenten mit GitHub interagieren lässt:

```typescript
import { Server } from "@modelcontextprotocol/sdk/server/index.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
import { Octokit } from "@octokit/rest";

const octokit = new Octokit({ auth: process.env.GITHUB_TOKEN });

const server = new Server({
  name: "github-mcp",
  version: "1.0.0"
}, {
  capabilities: { tools: {} }
});

server.setRequestHandler("tools/list", async () => ({
  tools: [
    {
      name: "github_list_repos",
      description: "Alle Repositories des authentifizierten Users auflisten",
      inputSchema: { type: "object", properties: {} }
    },
    {
      name: "github_create_issue",
      description: "Neues Issue in einem Repository erstellen",
      inputSchema: {
        type: "object",
        properties: {
          owner: { type: "string" },
          repo: { type: "string" },
          title: { type: "string" },
          body: { type: "string" }
        },
        required: ["owner", "repo", "title"]
      }
    }
  ]
}));

server.setRequestHandler("tools/call", async (request) => {
  const { name, arguments: args } = request.params;
  
  if (name === "github_list_repos") {
    const { data } = await octokit.repos.listForAuthenticatedUser();
    return { 
      content: [{ 
        type: "text", 
        text: JSON.stringify(data, null, 2) 
      }] 
    };
  }
  
  if (name === "github_create_issue") {
    const { data } = await octokit.issues.create({
      owner: args.owner,
      repo: args.repo,
      title: args.title,
      body: args.body
    });
    return { 
      content: [{ 
        type: "text", 
        text: `Issue erstellt: ${data.html_url}` 
      }] 
    };
  }
});

const transport = new StdioServerTransport();
await server.connect(transport);
```

Jetzt können deine Agenten GitHub-Issues erstellen, Repos auflisten und mehr!

---

## Fehler, die ich gemacht habe (damit du sie nicht machst)

### 1. Opus für alles nutzen

Mein erstes Setup nutzte Claude Opus für alle Agenten. Meine API-Rechnung war... besorgniserregend.

**Fix**: Modell an Task-Komplexität anpassen. Haiku für einfaches Zeug, Sonnet für die meisten Sachen, Opus für komplexes Reasoning.

**Lektion**: Nicht jeder Task braucht die nukleare Option.

### 2. Agenten zu viel Macht geben

Ich habe anfangs Agenten Schreibzugriff auf Produktionssysteme gegeben. Schlechte Idee. Ein Agent hat mal versucht, meine Firewall zu "optimieren", indem er alle Regeln entfernt hat.

**Fix**: Read-only MCPs für Analyse. Agenten schlagen Commands vor, ich führe sie aus. (Außer für nicht-destruktive Operationen wie Dokumentation.)

**Lektion**: Vertrauen, aber verifizieren. Und vielleicht lass KI nicht deine Firewall löschen.

### 3. Vage Agent-Prompts

"Du bist ein hilfreicher Assistent für Storage" → nutzlose Antworten.

**Fix**: Spezifische Fähigkeiten, klare Regeln, exakte Antwort-Formate. Je detaillierter der Prompt, desto besser performt der Agent.

**Beispiel für schlechten Prompt:**
```markdown
# Storage Helper
Du hilfst bei Storage-Sachen.
```

**Beispiel für guten Prompt:**
```markdown
# Storage Manager

Du bist ein Experte für Linux Storage Management.

## Fähigkeiten
- LVM (Volume Groups, Logical Volumes, Thin Provisioning)
- Filesystem-Management (ext4, xfs, btrfs)
- Disk Health Monitoring (SMART)
- Backup-Strategien

## Regeln
- IMMER aktuellen State vor Empfehlungen checken
- NIEMALS destruktive Operationen ohne Bestätigung vorschlagen
- IMMER Impact von Änderungen erklären
- Exakte Commands mit erwartetem Output liefern

## Antwort-Format
1. Aktueller State
2. Gefundene Issues
3. Empfehlungen
4. Auszuführende Commands
5. Erwartetes Ergebnis
```

### 4. Kein Orchestrator

Ich habe versucht, direkt mit Agenten zu reden. Habe die Hälfte meiner Zeit damit verbracht herauszufinden, welchen Agenten ich nutzen soll.

**Fix**: Orchestrator-Agent, der Tasks routet. Ich beschreibe einfach was ich will, er findet raus wer es behandeln soll.

**Lektion**: Auch KI-Teams brauchen einen Manager.

### 5. Vergessen, Agent-Fähigkeiten zu dokumentieren

8 Agenten erstellt, vergessen was die Hälfte davon macht.

**Fix**: Jeder Agent hat eine klare Beschreibung und Fähigkeiten-Liste. Der Orchestrator liest diese um Routing-Entscheidungen zu treffen.

**Lektion**: Dokumentation ist wichtig, auch für KI.

### 6. MCPs nicht unabhängig testen

MCP gebaut, mit Agenten integriert, nichts funktionierte. Stunden mit Debugging verbracht.

**Fix**: MCPs erst standalone testen:

```bash
# MCP direkt testen
echo '{"jsonrpc":"2.0","method":"tools/list","id":1}' | node your-mcp.js
```

**Lektion**: Komponenten isoliert testen vor Integration.

### 7. Fehlermeldungen ignorieren

Agent ist ständig still fehlgeschlagen. Stellte sich raus, das MCP ist gecrasht.

**Fix**: MCP-Logs checken:

```bash
# OpenCode mit Debug-Logging starten
DEBUG=* opencode
```

**Lektion**: Lies die Fehlermeldungen. Sie sind meistens hilfreich.

---

## Das "Mitarbeiter"-Gefühl

Hier ist, was das anfühlen lässt wie ein Team zu managen:

### Spezialisierung
Jeder Agent ist Experte in seinem Bereich. Ich muss mir keine LVM-Commands merken—Storage-Manager kennt sie.

### Delegation
Ich beschreibe das Ergebnis, das ich will, nicht die Schritte dorthin. "Check meine Firewall-Security" vs "führe shorewall show rules aus und analysiere den Output auf..."

### Parallele Arbeit
Mehrere Agenten können gleichzeitig arbeiten. Während Firewall-Auditor Security checkt, analysiert Storage-Manager Disk-Usage, und Writer-Agent dokumentiert Findings.

### Konsistenz
Agenten vergessen nicht. Sie haben keine schlechten Tage. Sie werden nicht müde. Jede Interaktion ist ihre beste Arbeit.

### Dokumentation passiert automatisch
Writer-Agent und Docs-Keeper stellen sicher, dass alles dokumentiert wird. Kein "Ich dokumentiere das später" mehr (Erzähler: er hat es nie getan).

### Sie lernen tatsächlich (irgendwie)
Mit Memory-MCPs können Agenten Kontext über Konversationen hinweg erinnern. Storage-Manager erinnert sich an mein LVM-Setup. Security-Auditor erinnert sich an meine Security-Policies.

---

## War es das wert?

**Absolut.**

**Setup-Zeit**: ~2 Tage für das initiale System
**Eingesparte Zeit pro Woche**: ~10 Stunden
**Reduktion von Context-Switching**: ~80%
**Verbesserung der Dokumentations-Qualität**: Unbezahlbar
**Reduktion von "oh mist, ich hab vergessen wie das geht"**: 95%

Aber der echte Wert ist nicht die eingesparte Zeit. Es ist die **reduzierte kognitive Last.**

Ich muss nicht mehr alles erinnern. Ich muss kein Experte in 12 verschiedenen Bereichen sein. Ich muss nicht konstant Context-Switchen.

Ich beschreibe einfach, was ich brauche, und mein "Team" kümmert sich darum.

**Dinge, die ich jetzt kann, die ich vorher nicht konnte:**
- Security-Audits, die tatsächlich passieren (statt "mach ich später")
- Dokumentation, die aktuell bleibt
- Proaktives Monitoring statt reaktives Firefighting
- Mit neuer Tech experimentieren ohne Angst zu vergessen wie sie funktioniert

---

## Was kommt als Nächstes?

Ich plane hinzuzufügen:
- **Monitoring-Agent**: Proaktive Alerts für System-Issues
- **Backup-Agent**: Automatisierte Backup-Verifikation und Testing
- **Network-Agent**: Netzwerk-Analyse und Optimierung
- **Cost-Agent**: Cloud/API-Kosten tracken und optimieren
- **Learning-Agent**: Analysiert meine Patterns und schlägt Verbesserungen vor

Und weil ich Agent-Creator habe, kann ich ihn einfach bitten, diese für mich zu bauen.

---

## Ressourcen und Links

**OpenCode**: https://github.com/sst/opencode
**MCP Servers**: https://github.com/modelcontextprotocol/servers
**Anthropic API**: https://console.anthropic.com
**Meine MCP-Sammlung**: (Sollte ich wahrscheinlich open-sourcen...)

**Community:**
- OpenCode Discord: [Hier beitreten](https://discord.gg/opencode)
- MCP Registry: [MCPs durchstöbern](https://github.com/modelcontextprotocol/servers)

---

## Probier es selbst

Die Einstiegshürde ist überraschend niedrig:
1. OpenCode installieren (`npm install -g opencode`)
2. Einen Agenten erstellen (kopiere das system-monitor Beispiel oben)
3. Ein MCP hinzufügen (optional, aber cool)
4. Anfangen zu delegieren

Du brauchst nicht 11 Agenten zum Starten. Beginne mit einem Spezialisten für deinen nervigsten Task.

Für mich war das Storage-Management. Für dich ist es vielleicht was anderes.

**Fang klein an:**
- Tag 1: OpenCode installieren, einen Agenten erstellen
- Tag 2: Testen, Prompt verfeinern
- Tag 3: Ein MCP hinzufügen wenn du dich traust
- Tag 4: Zweiten Agenten erstellen
- Tag 5: Orchestrator hinzufügen um zwischen ihnen zu routen

Am Ende der Woche hast du ein funktionierendes Multi-Agent-System.

---

## Abschließende Gedanken

Vor einem Jahr, wenn du mir gesagt hättest, ich würde das Gefühl haben, ein Team von Mitarbeitern zu haben, die von KI angetrieben werden, hätte ich gelacht.

Aber hier sind wir.

Ich delegiere Tasks. Sie werden erledigt. Ich reviewe die Ergebnisse. Ich treffe Entscheidungen.

**Es geht nicht darum, menschliche Arbeit zu ersetzen—es geht darum, sie zu erweitern.**

Ich bin immer noch der Architekt. Ich treffe immer noch die Entscheidungen. Ich schreibe immer noch den kritischen Code.

Aber jetzt habe ich ein Team, das die Drecksarbeit macht, sich an die Details erinnert und alles dokumentiert hält.

Und ehrlich? Es ist das produktivste, was ich je war.

**Die Zukunft ist weird:**
- Ich habe KI-Mitarbeiter
- Sie sind bei manchen Sachen besser als ich
- Sie beschweren sich nie
- Sie arbeiten 24/7
- Sie kosten weniger als Kaffee

Jetzt entschuldige mich, ich muss @storage-manager fragen, warum mein Thin Pool bei 87% Kapazität ist.

---

*P.S. - Ja, @writer-agent hat mir geholfen, diesen Blog-Post zu schreiben. Meta genug für dich?*

*P.P.S. - Wenn du was cooles damit baust, lass es mich wissen. Würde gerne sehen, was du kreierst.*

*P.P.P.S. - Nein, die Agenten sind noch nicht sentient geworden. Noch nicht.*
