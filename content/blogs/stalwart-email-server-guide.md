---
title: "Building My Own Email Server with Stalwart: A Journey to 10/10 (Except Microsoft)"
date: 2025-12-11
draft: false
tags: ["email", "stalwart", "self-hosting", "proxmox", "lxc", "dns", "smtp", "homelab"]
categories: ["Self-Hosting", "Homelab", "Tutorials"]
description: "A complete guide to setting up a self-hosted email server with Stalwart Mail Server, Snappymail webmail, and all the DNS records you need. Plus the ongoing saga of Microsoft blocking my perfectly configured server."
---

# Building My Own Email Server with Stalwart: A Journey to 10/10 (Except Microsoft)

**TL;DR**: I spent mass time setting up my own mail server using Stalwart in an LXC container on Proxmox. I got a perfect 10/10 score on mail-tester.com, all major providers accept my emails... except Microsoft, who decided my Hetzner IP is guilty by association. Here's the complete guide, including all the DNS records, firewall configs, and the ongoing Microsoft saga.

---

## Why Run Your Own Mail Server in 2025?

Let me start with the truth: running your own mail server in 2025 is widely considered a terrible idea. Gmail and Outlook are free, reliable, and "just work." The internet is full of articles titled "Why You Should Never Run Your Own Mail Server" and they all have excellent points.

So why did I do it anyway?

1. **Learning** - I wanted to understand email infrastructure from the ground up: SMTP, IMAP, DNS records, SPF, DKIM, DMARC, and all those acronyms
2. **Control** - My emails, my server, my rules. No big tech company scanning my content or changing terms of service
3. **Professional Experience** - Email servers are still everywhere in enterprise environments. Understanding them is valuable
4. **Because I Could** - I have a Proxmox homelab and a domain. Sometimes that's reason enough

> ⚠️ **Reality Check**: If you just want email that works reliably, use [Fastmail](https://fastmail.com), [Migadu](https://migadu.com), or [ProtonMail](https://proton.me). They're affordable, professional, and won't make you cry when Microsoft blocks you. If you want to learn, tinker, and occasionally curse at your screen... welcome to the club.

## Prerequisites

Before we dive in, here's what you'll need:

### Hardware
- A server with a static public IP (I'm using a Hetzner dedicated server running Proxmox VE)
- At least 1GB RAM for the mail server (I allocated 2GB to be safe)
- Storage for emails (depends on usage, I started with 32GB)

### Software/Services
- **Domain name** with DNS control (I'm using engels.wtf)
- **Reverse DNS** capability (your hosting provider must allow PTR records)
- **LXC or VM** capability (I'm using Proxmox with LXC containers)
- **Basic Linux knowledge** (comfortable with command line, editing configs)

### The Patience Factor
- Time to wait for DNS propagation (up to 24-48 hours)
- Willingness to debug SMTP rejections
- Mental fortitude for dealing with Microsoft (ongoing)

> 💡 **Critical**: Most residential ISPs block port 25 and won't give you reverse DNS. You'll need a VPS or dedicated server.

---

## Part 1: Setting Up the LXC Container

I'm running everything in an LXC container on Proxmox because it's lighter than a VM and easier to manage than installing directly on the host.

### Container Specs

```bash
VMID: 107
Hostname: mail.engels.wtf
Template: Debian 12 (bookworm)
Cores: 2
RAM: 2048 MB
Storage: 32 GB
Network: 10.10.10.107/24 (internal)
```

### Installing Stalwart

I chose [Stalwart Mail Server](https://stalw.art) because:
- Modern, written in Rust (fast and secure)
- All-in-one: SMTP, IMAP, JMAP, spam filtering
- Great documentation
- Active development
- Built-in admin UI

```bash
apt update && apt upgrade -y
curl -sSL https://get.stalw.art | sh
```

After installation, Stalwart runs on:
- **SMTP**: Port 25 (receiving mail)
- **Submission**: Port 587 (sending mail, with auth)
- **SMTPS**: Port 465 (sending mail, SSL)
- **IMAPS**: Port 993 (reading mail, SSL)
- **HTTP**: Port 8080 (admin UI and API)

> 💡 **Important**: Stalwart stores most configuration in its embedded database, not just in config.toml. You'll manage settings via the admin UI or API.

---

## Part 2: Firewall Configuration (Shorewall)

Here's what I added to /etc/shorewall/rules on the Proxmox host:

```bash
# Mail server (LXC 107) - DNAT from public IP to container
DNAT    net     loc:10.10.10.107:25     tcp     25      -       49.12.126.61
DNAT    net     loc:10.10.10.107:587    tcp     587     -       49.12.126.61
DNAT    net     loc:10.10.10.107:465    tcp     465     -       49.12.126.61
DNAT    net     loc:10.10.10.107:993    tcp     993     -       49.12.126.61
ACCEPT  net     loc:10.10.10.107        tcp     25,587,465,993
```

---

## Part 3: The DNS Configuration (Don't Skip This!)

This is where most people fail. Email requires **multiple** DNS records.

### Essential Records

| Type | Name | Value |
|------|------|-------|
| A | mail | 49.12.126.61 |
| MX | @ | 10 mail.engels.wtf |
| TXT | @ | v=spf1 mx a:mail.engels.wtf -all |
| TXT | _dmarc | v=DMARC1; p=reject; rua=mailto:postmaster@engels.wtf |
| TXT | 202512e._domainkey | v=DKIM1; k=ed25519; p=YOUR_KEY |
| TXT | 202512r._domainkey | v=DKIM1; k=rsa; p=YOUR_KEY |
| PTR | 49.12.126.61 | mail.engels.wtf |

> ⚠️ **Important**: Create a postmaster@engels.wtf account! It's required by RFC and Microsoft checks for it.

---

## Part 4: Adding Webmail (Snappymail)

Stalwart doesn't include a webmail interface, so I installed Snappymail.

```bash
apt install nginx php8.2-fpm php8.2-curl php8.2-xml php8.2-zip -y
cd /var/www
wget https://github.com/the-djmaze/snappymail/releases/latest/download/snappymail-latest.tar.gz
tar -xzf snappymail-latest.tar.gz -C /var/www/snappymail
chown -R www-data:www-data /var/www/snappymail
```

> ⚠️ **Critical Gotcha**: In the Snappymail domain config, "type": 1 must be an INTEGER, not a string "1". This broke for me multiple times!

---

## Part 5: Testing & Victory (Almost)

### Mail-Tester Result: 10/10 🎉

Perfect score! SPF, DKIM, DMARC all passing.

### Real-World Tests

- ✅ Gmail - Delivered to inbox
- ✅ ProtonMail - Delivered to inbox
- ❌ Outlook.com/Hotmail - **REJECTED**

---

## Part 6: The Microsoft Saga

```
550 5.7.1 Service unavailable; Client host [49.12.126.61] blocked using S3140
```

Microsoft blocks entire Hetzner IP ranges because other customers have sent spam. It's guilt by association.

### What I Tried
1. **SNDS** - Registered, shows "No data"
2. **JMRP** - Form was buggy
3. **Delisting Request** - "Your IP does not qualify for mitigation"

### Current Status
- Gmail, ProtonMail: ✅ Working
- Microsoft: ❌ Still blocked

---

## Part 7: Mistakes I Made

1. **Thinking config.toml was everything** - Stalwart uses a database
2. **Snappymail JSON type error** - Integer vs string cost me an hour
3. **Forgetting postmaster@** - Required by RFC
4. **Expecting Microsoft to be reasonable** - Don't.

---

## Conclusion: Was It Worth It?

### The Good ✅
- 10/10 mail-tester score
- Full control over my email
- Deep learning experience
- Works with 95% of providers

### The Bad ❌
- Microsoft blocks me
- Maintenance responsibility
- Complexity

**Would I do it again?** Yes, but only because I enjoy tinkering.

---

## Resources

- [Stalwart Documentation](https://stalw.art/docs)
- [Snappymail](https://snappymail.eu/)
- [Mail-tester](https://mail-tester.com)
- [MXToolbox](https://mxtoolbox.com)

---

Got questions? Reach out at luca@engels.wtf (yes, it works... mostly).

**Update 2025-12-11**: Still blocked by Microsoft. The saga continues.
