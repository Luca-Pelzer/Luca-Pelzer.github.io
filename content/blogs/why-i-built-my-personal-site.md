---
title: "Why I Built My Personal Site: More Than Just Another Tech Blog"
date: 2025-12-10
draft: false
tags: ["meta", "blogging", "homelab", "self-hosting", "hugo", "documentation"]
categories: ["Meta", "Homelab"]
description: "Why I built my own blog from scratch, how it's set up in my homelab, and why blogging is the best knowledge management system I've found."
---

# Why I Built My Personal Site: More Than Just Another Tech Blog

**TL;DR**: I built my own blog using Hugo, running in an LXC container on Proxmox, with Flatnotes as my writing companion. It's not just about sharing knowledge—it's about building a personal knowledge base that actually sticks in my brain.

---

## The Problem: "Wait, How Did I Fix That Again?"

You know that feeling when you solve a tricky problem at 2 AM, feel like a genius, then three months later encounter the exact same issue and have absolutely no idea what you did?

Yeah, me too. Way too often.

I've been tinkering with my homelab for a while now—setting up containers, breaking things, fixing them, breaking them again. I'd solve something, think "oh, I'll remember this," and then promptly forget everything except that it was painful.

I tried keeping notes in random text files. I tried bookmarking solutions. I even tried just Googling my own Stack Overflow questions (yes, I've done this). Nothing stuck.

Then I realized: **I need to write about it like I'm explaining it to someone else.**

## Why Blogging is Actually a Superpower

Here's what I've learned about writing blog posts versus just "taking notes":

### 1. **Writing Teaches You Twice**

When you write a blog post, you can't just dump commands into a file. You have to:
- Explain *why* you're doing something
- Provide context for future-you (or anyone else)
- Think through the logic step-by-step
- Fill in gaps you didn't realize you had

I've lost count of how many times I thought I understood something, started writing about it, and realized "wait, why does this work?" That's when the real learning happens.

### 2. **Your Future Self Will Thank You**

Six months from now when my mail server has issues (let's be honest, it will), I won't remember the exact DKIM selector I used or where I put that DNS record. But I'll have a blog post titled "Setting Up Stalwart Mail Server" with every detail documented.

**Past me is helping future me.** It's like leaving care packages for yourself in the future.

### 3. **You Help Others (and That Feels Good)**

The number of times I've been saved by someone's random blog post from 2015 is ridiculous. Some person I'll never meet solved the exact problem I had and documented it.

Now I get to pay it forward. And honestly? It feels pretty good knowing that my 2 AM debugging session might save someone else's 2 AM debugging session.

### 4. **Accountability Keeps Things Clean**

When you know you might write about something publicly, you tend to do it properly. No more "temporary" fixes that become permanent. No more "I'll clean this up later" (narrator: he did not clean it up later).

Writing about my setup forces me to actually understand and document my infrastructure properly.

---

## The Technical Setup: How This Blog Actually Works

Alright, enough philosophy. Let's talk about how this blog is actually built.

### The Stack

- **Static Site Generator**: Hugo (fast, simple, and no PHP vulnerabilities to worry about)
- **Theme**: Hugo Noir (clean, minimal, fast)
- **Hosting**: LXC container (ID: 106) on my Proxmox server
- **Reverse Proxy**: Caddy (on LXC 104) handling SSL and routing
- **Writing Environment**: Flatnotes (a self-hosted note-taking app)
- **Multi-language**: Built-in support for English, German, and Spanish

### Architecture Overview

```
Internet
    ↓
Cloudflare (DNS + CDN)
    ↓
Caddy Proxy (LXC 104, 10.10.20.10)
    ↓
Hugo Server (LXC 106, 10.10.20.106:1313)
```

### Why LXC Instead of Docker?

I know, I know—everyone uses Docker for everything. But here's the thing: **LXC containers are perfect for long-running services like this.**

- Lightweight (1GB RAM, 2 CPU cores, 8GB storage)
- Feels like a real VM but uses way fewer resources
- Easy to snapshot and backup in Proxmox
- No Docker overhead for a single application
- Can still use Docker inside if I want (I do for Flatnotes)

### The Hugo Server Service

I set up Hugo to run as a systemd service, so it automatically starts on boot:

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
  --baseURL https://engelswtf.github.io \
  --appendPort=false \
  --environment production \
  --disableLiveReload
Restart=always

[Install]
WantedBy=multi-user.target
```

Hugo's built-in server is surprisingly robust for production use. It serves static files quickly, handles the multi-language routing, and automatically rebuilds when I add new content.

> 💡 **Tip**: I used to think you needed nginx or Apache in front of Hugo. Nope. Caddy reverse proxy + Hugo server = perfectly fine for a personal blog.

### Caddy: The Best Reverse Proxy You're Not Using

My Caddy configuration for the blog is beautifully simple:

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
    redir https://engelswtf.github.io{uri} permanent
}
```

That's it. Caddy handles:
- ✅ Automatic SSL certificates from Let's Encrypt
- ✅ HTTP to HTTPS redirect
- ✅ Apex to www redirect
- ✅ Security headers
- ✅ Reverse proxying to the Hugo container

No cryptic nginx configs. No spending 3 hours debugging SSL certificates. It just works.

### The Secret Weapon: Flatnotes

Here's where it gets interesting. I run [Flatnotes](https://github.com/dullage/flatnotes) in a Docker container on the same LXC as Hugo:

```
notes.engels.wtf → Password-protected Flatnotes interface
                 → Writes directly to /var/www/engels-blog/content/blogs/
                 → Hugo auto-rebuilds when it detects new files
```

This means I can:
1. Open notes.engels.wtf on any device
2. Write a blog post in Markdown
3. Save it
4. Hugo automatically detects the new file and rebuilds
5. New post is live within seconds

**No Git commits. No SSH-ing into the server. No build pipelines.** Just write and save.

> ⚠️ **Security Note**: Flatnotes is behind basic authentication. Don't expose note-taking apps without authentication!

---

## Multi-Language: Because Why Not?

One thing I wanted from the start was multi-language support. My config supports:
- 🇬🇧 English (primary)
- 🇩🇪 German (my native language)
- 🇪🇸 Spanish (for practice and broader reach)

Hugo makes this surprisingly easy. Each blog post can have language variants:
- `post.md` (English)
- `post.de.md` (German)
- `post.es.md` (Spanish)

The theme automatically generates language switchers, and users get the right version based on their browser language.

Do I write everything in all three languages? Not always. But having the infrastructure in place means I can when it makes sense.

---

## What I Learned Building This

### Mistakes I Made

**1. Overthinking the infrastructure**

I initially planned a whole CI/CD pipeline with Git webhooks and automated deployments. Then I realized: this is a personal blog, not a corporate application. Hugo's built-in file watching + Flatnotes = perfectly good enough.

**2. Spending too long on design**

I wasted hours tweaking CSS before I had any content. Turns out, nobody cares about your perfect color scheme if there's nothing to read. Content first, polish later.

**3. Forgetting to set up backups initially**

Yeah, I ran the blog for a few hours before realizing "wait, I should probably back this up." Now I have Proxmox snapshots scheduled daily.

### What I'd Do Differently

- **Start with a simple theme**: Hugo Noir is great, but I spent too long comparing themes. Pick something clean and move on.
- **Write more, publish sooner**: Perfectionism kills blogs. Done is better than perfect.
- **Set up analytics from day one**: I added this later and now I'm missing early data (not that there was much traffic anyway).

---

## The Blog as a Knowledge Management System

Here's the real reason this whole thing exists: **my brain is unreliable.**

I can't remember the specific Shorewall rule I need for allowing SMTP, but I can remember "oh yeah, I wrote about that mail server setup." 

I can't recall the exact LVM commands for extending a logical volume, but I can search my own blog for "LVM."

This blog isn't just for other people—**it's my external brain.**

Every time I solve a problem, I write about it. Every time I set up something new, I document it. Every time I make a mistake (which is often), I record what went wrong and how I fixed it.

Six months from now when I inevitably need to do something I did before, I won't be starting from scratch. I'll have step-by-step documentation written by someone who actually went through the process—past me.

---

## What's Next?

Now that the infrastructure is running, the real work begins: actually writing regularly.

Upcoming posts I'm planning:
- **Setting Up Stalwart Mail Server** (because I just did this today and it was an adventure)
- **Proxmox Network Tuning** (fixing that IRQ issue that made my server lag)
- **Self-Hosting n8n for Automation** (my workflow automation setup)
- **Building a Multi-Language Hugo Blog** (meta, but useful for others)

## Want to Build Your Own?

The whole setup is pretty straightforward. If you've got a Proxmox server (or any Linux box), you can replicate this in an afternoon:

1. Create an LXC container
2. Install Hugo
3. Pick a theme
4. Configure Caddy as a reverse proxy
5. (Optional) Add Flatnotes for easy editing
6. Start writing

The hardest part isn't the technical setup—it's actually sitting down and writing. But that's a problem no amount of infrastructure can solve.

---

## Final Thoughts

Building this blog took maybe 4 hours of actual work. Most of that was tweaking configurations and setting up Flatnotes.

But the value? Immeasurable.

Every post I write is an investment in future-me's sanity. Every tutorial I document is one less problem I'll have to solve twice. Every mistake I record is a lesson I won't have to relearn.

If you're tinkering with homelabs, self-hosting, or infrastructure, **start documenting.** Your future self will thank you. And who knows—maybe you'll help someone else solve the exact problem they're stuck on at 2 AM.

That's why `engels.wtf` exists. Not just as a blog, but as a living knowledge base that grows every time I learn something new.

Now if you'll excuse me, I have about 47 other things I should probably write about before I forget them.
