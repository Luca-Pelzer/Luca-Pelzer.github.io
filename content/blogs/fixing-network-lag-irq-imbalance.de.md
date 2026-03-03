---
title: "Wenn Dein Server nur laggt, wenn Du nicht hinschaust: IRQ-Imbalance beheben"
date: 2025-12-11
draft: false
tags: ["proxmox", "netzwerk", "performance-tuning", "debugging", "linux", "irq-balance", "homelab"]
categories: ["Homelab", "Performance", "Tutorials"]
description: "Mysteriöses Netzwerk-Lag, das verschwand, sobald Monitoring startete? Es war IRQ-Imbalance - alle Netzwerk-Interrupts auf einem CPU-Kern. So diagnostizierst und fixst du es."
---

# Wenn Dein Server nur laggt, wenn Du nicht hinschaust: IRQ-Imbalance beheben

**TL;DR**: Mein Proxmox-Server hatte mysteriöse Netzwerk-Lags, die verschwanden, sobald ich `htop` öffnete. Alle Netzwerk-Interrupts wurden von einem einzigen CPU-Kern verarbeitet. Nach Aktivierung von `irqbalance`, RPS-Tuning und Anpassung der Netzwerk-Buffer war das Lag endgültig weg. Hier erfährst du, wie du IRQ-Imbalance auf deinem eigenen Server diagnostizierst und behebst.

---

## Der Observer-Effect-Bug

Kennst du das Gefühl, wenn dein Auto wochenlang komische Geräusche macht, aber in dem Moment, wo du es zur Werkstatt fährst, läuft es perfekt? So war es letzten Monat mit meinem Proxmox-Server.

**Die Symptome:**
- Zufällige Netzwerk-Lag-Spitzen (200-500ms Ping-Sprünge)
- Container-Webservices, die gelegentlich timeouts hatten
- SSH-Sessions, die zufällig für 2-3 Sekunden einfroren
- **Der Hammer:** In dem Moment, wo ich per SSH eingeloggt war und `htop` oder Netdata öffnete, lief alles smooth

Das ist die frustrierendste Art von Bug - einer, der sich versteckt, sobald man versucht, ihn zu beobachten. Schrödingers Lag sozusagen.

> 💡 **Tipp**: Das ist keine Magie. Wenn du Monitoring-Tools startest, erzeugen sie Prozesse auf verschiedenen CPU-Kernen, was temporär die Workload verschiebt und dem überlasteten Kern eine Verschnaufpause gibt.

## Voraussetzungen

Bevor wir loslegen, brauchst du:
- Einen Linux-Server (ich nutze Proxmox, aber das funktioniert auf jedem Debian/Ubuntu-basierten System)
- Root-Zugriff
- Grundlegende Kommandozeilen-Kenntnisse
- Etwa 30 Minuten für Diagnose und Fixes
- Geduld (bei einigem davon muss man Zählern beim Hochzählen zusehen)

---

## Schritt 1: Zuerst Security-Check

Wenn plötzlich merkwürdige Performance-Probleme auftauchen, ist mein erster Gedanke immer: **"Hat sich jemand eingehackt?"**

```bash
# Nach verdächtigen Prozessen suchen
ps aux | grep -iE 'xmr|crypto|mine' 

# Nach unauthorisierten SSH-Keys suchen
cat ~/.ssh/authorized_keys

# Auf Rootkits prüfen
apt install -y chkrootkit rkhunter
chkrootkit
rkhunter --check --skip-keypress

# Laufende Netzwerkverbindungen überprüfen
netstat -tulpn | grep ESTABLISHED
```

Alles war sauber. Keine Crypto-Miner, keine verdächtigen Prozesse, kein unautorisierter Zugriff.

> ⚠️ **Warnung**: Überspringe diesen Schritt niemals. Performance-Probleme können Symptome einer Kompromittierung sein.

---

## Schritt 2: Die IRQ-Imbalance entdecken

### Was sind IRQs überhaupt?

**IRQ (Interrupt Request)** ist die Art, wie Hardware-Geräte (wie deine Netzwerkkarte) die Aufmerksamkeit der CPU bekommen. Wenn ein Netzwerkpaket ankommt, sagt die NIC "Hey CPU, ich hab was für dich!" via Interrupt.

```bash
# Interrupt-Verteilung in Echtzeit beobachten
watch -n 2 'cat /proc/interrupts | grep -E "CPU|eth0|eno1|enp"'
```

> 💡 **Tipp**: Ersetze `eth0` oder `eno1` mit deinem tatsächlichen Netzwerk-Interface-Namen. Finde ihn mit `ip link show`.

Das habe ich gesehen:

```
           CPU0   CPU1   CPU2   CPU3   CPU4   CPU5   ...
eth0-TxRx  3301245    0      0      0      0      0   ...
```

**Autsch.** Alle 3,3 Millionen Interrupts nur auf CPU0. Jedes einzelne Netzwerkpaket von einem Kern verarbeitet, während die anderen 11 Kerne rumchillten.

### Softirqs checken

```bash
watch -n 2 'cat /proc/softirqs | grep -E "CPU|NET_RX"'
```

CPU0 verarbeitete **10x mehr** Receive-Softirqs als andere Kerne. Das war die rauchende Waffe.

---

## Schritt 3: Der Fix (Mehrere Schichten)

### Schicht 1: irqbalance installieren

```bash
apt install -y irqbalance
systemctl enable --now irqbalance
systemctl status irqbalance
```

### Schicht 2: RPS aktivieren (Receive Packet Steering)

```bash
# Finde deinen Interface-Namen
ip link show

# RPS für alle CPUs aktivieren (passe den Hex-Wert an deine CPU-Anzahl an)
# fff = 12 CPUs in hex, f = 4 CPUs, ff = 8 CPUs, ffff = 16 CPUs
echo "fff" > /sys/class/net/eth0/queues/rx-0/rps_cpus
```

**Wie man die RPS-Maske berechnet:**
- Zähle deine CPU-Kerne: `nproc`
- Konvertiere zu hex: 4 CPUs = `f`, 8 = `ff`, 12 = `fff`, 16 = `ffff`

### Schicht 3: NIC Ring-Buffer erhöhen

```bash
# Aktuelle Größe checken
ethtool -g eth0

# Auf Maximum erhöhen
ethtool -G eth0 rx 4096 tx 4096
```

### Schicht 4: Network-Stack tunen (sysctl)

Erstelle `/etc/sysctl.d/99-network-tuning.conf`:

```bash
# Socket-Buffer-Größen erhöhen (128MB)
net.core.rmem_max = 134217728
net.core.wmem_max = 134217728

# TCP-Buffer Auto-Tuning
net.ipv4.tcp_rmem = 4096 87380 67108864
net.ipv4.tcp_wmem = 4096 65536 67108864

# Network-Device-Backlog-Queue erhöhen
net.core.netdev_max_backlog = 5000

# Softirq-Processing-Budget erhöhen
net.core.netdev_budget = 600
```

Anwenden:

```bash
sysctl -p /etc/sysctl.d/99-network-tuning.conf
```

---

## Schritt 4: Persistent machen

Erstelle `/etc/systemd/system/network-tuning.service`:

```ini
[Unit]
Description=Network Performance Tuning
After=network-online.target
Wants=network-online.target

[Service]
Type=oneshot
RemainAfterExit=yes
# Ersetze eth0 mit deinem Interface-Namen und fff mit deiner CPU-Maske
ExecStart=/bin/bash -c 'echo "fff" > /sys/class/net/eth0/queues/rx-0/rps_cpus'
ExecStart=/usr/sbin/ethtool -G eth0 rx 4096 tx 4096

[Install]
WantedBy=multi-user.target
```

Aktivieren:

```bash
systemctl daemon-reload
systemctl enable network-tuning.service
systemctl start network-tuning.service
```

---

## Schritt 5: Den Fix verifizieren

```bash
# Interrupt-Verteilung überwachen
watch -n 2 'cat /proc/interrupts | grep -E "CPU|eth0"'

# Auf Paket-Drops checken
netstat -s | grep -iE 'drop|prune|collapse'

# Softirq-Verteilung beobachten
watch -n 2 'cat /proc/softirqs | grep -E "CPU|NET_RX"'
```

---

## Fehler, die ich gemacht habe

1. **Habe Security nicht zuerst gecheckt**: Immer zuerst Security checken.
2. **Falsche RPS-Maske verwendet**: Mit `nproc` checken!
3. **Vergessen, Settings persistent zu machen**: Immer den systemd-Service erstellen.
4. **Habe vorher/nachher nicht überwacht**: Immer den "Vorher"-Zustand dokumentieren.

---

## Was ich gelernt habe

- **irqbalance sollte Standard sein** auf jedem Server mit echtem Traffic
- **Der "Observer-Effect" ist keine Magie** - es ist der Scheduler unter Last
- **Netzwerk-Tuning ist ein Stack** - Hardware-IRQs, RPS, Buffer, sysctl arbeiten zusammen
- **Moderne NICs brauchen moderne Settings** - 256-Paket-Buffer sind zu klein für Gigabit

---

## Rollback (falls nötig)

```bash
systemctl stop network-tuning.service
systemctl disable network-tuning.service
ethtool -G eth0 rx 256 tx 256
rm /etc/sysctl.d/99-network-tuning.conf
sysctl -p
systemctl stop irqbalance
systemctl disable irqbalance
reboot
```

---

## Ressourcen

- [Linux Kernel Documentation: Scaling](https://www.kernel.org/doc/Documentation/networking/scaling.txt)
- [irqbalance auf GitHub](https://github.com/Irqbalance/irqbalance)

---

*Update 2025-12-11: Erstveröffentlichung*
