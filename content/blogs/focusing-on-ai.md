---
title: "The Inevitable Pivot: Why All My Projects Now Lead to AI"
date: 2025-01-11
draft: false
tags: ["ai", "automation", "opencode", "agents", "workflows", "meta", "productivity"]
categories: ["AI", "Meta"]
description: "I came here to build a homelab and write about self-hosting. Somehow I ended up with 110 prompts, 28 agents, and the realization that I've been building AI infrastructure this whole time."
---

# The Inevitable Pivot: Why All My Projects Now Lead to AI

**TL;DR**: I started this blog to document my homelab adventures. Somewhere along the way, I built 110 prompts and 28 specialized agents across infrastructure, development, content, and research. Every project I touch now seems to involve AI workflows. This isn't a pivot—it's just where everything naturally led.

---

## The Realization

You know that moment when you look up from your keyboard and realize you've been working on something completely different from what you intended?

I came here to self-host things. Email servers. Monitoring dashboards. Documentation wikis. The classic homelab stuff. And I did build all of that.

But then I looked at my recent commits. My open tabs. Where I actually spend my time.

**It's all AI.**

Not "I use ChatGPT sometimes" AI. I mean I've built an entire ecosystem:
- **110 prompts** organized into collections
- **28 specialized agents** with distinct roles
- **Custom MCP servers** that let AI actually interact with my infrastructure
- **Workflow templates** for everything from code review to incident response

I didn't plan this. It just... happened.

---

## What I've Actually Been Building

Let me be specific about what "focusing on AI" actually means in my case.

### The Agents (28 and counting)

I organized them into packs because apparently I'm building a trading card game:

**Infrastructure Pack (7 agents)**
- Storage Manager, Firewall Auditor, Security Auditor, VM Monitor
- These handle my actual homelab—the thing I originally came here to build

**Development Pack (7 agents)**
- Code Builder, DevOps Helper, Architect, Debug Specialist
- For when I need to write code that isn't just agent definitions

**Content Pack (6 agents)**
- Blog Writer, Documentation Keeper, Editor, Translator
- This very post? Probably could have delegated it, honestly

**Research Pack (8 agents)**
- Deep Researcher, Fact Checker, Source Analyzer, Trend Watcher
- For when I need to actually understand something before building it

### The Prompts (110 and growing)

Every workflow I repeat more than twice becomes a prompt. Code reviews. Incident analysis. Documentation updates. Security audits.

Some are simple:
> Review this PR for security issues, focusing on input validation and authentication.

Some are elaborate multi-step workflows that orchestrate multiple agents working together.

The point isn't the number. It's that I keep finding new things that benefit from structured AI workflows.

---

## Why This Happened

I've been asking myself: why AI? Why not just keep building normal homelab stuff?

### 1. The Leverage is Insane

When I write a good agent definition, it compounds. That Storage Manager agent I built? It's helped me with LVM issues maybe 50 times now. The time investment was a few hours. The return is ongoing.

Compare that to learning LVM commands by heart. Sure, I could memorize them. Or I could have an agent that knows them, explains the context, and prevents me from making dumb mistakes.

### 2. I'm a One-Person Department

Running a homelab solo means constant context-switching. I'm the sysadmin, the developer, the security team, the documentation writer, and the help desk.

Multi-agent workflows let me delegate. Not to humans (I don't have any of those), but to specialized AI that knows the domain. When I say "check the firewall config," I don't have to remember which Shorewall files to look at. The Firewall Auditor agent already knows.

### 3. The Infrastructure is Actually Fun to Build

Here's the honest truth: building AI workflows is more interesting to me than running yet another Docker container.

Setting up Stalwart mail server was cool. But building an MCP that lets an AI agent manage Discord servers? That's the kind of problem that keeps me up at night in a good way.

### 4. Everything Benefits

The weird thing is, the AI focus hasn't replaced my homelab work—it's enhanced it.

- My documentation is better because AI helps write and maintain it
- My security is tighter because agents audit it regularly  
- My debugging is faster because I can describe problems in natural language
- My learning is deeper because I have to understand things well enough to teach agents

The AI work isn't separate from the homelab work. It's the substrate everything else runs on.

---

## What This Means Going Forward

I'm not abandoning homelab content. I'll still write about self-hosting, Proxmox, and infrastructure when I do interesting things with them.

But I'm also not going to pretend AI isn't the main event anymore.

Expect more posts about:
- **Agent design patterns** — what makes a good vs. bad agent definition
- **MCP development** — building tools that let AI interact with real systems
- **Workflow orchestration** — how to get multiple agents working together
- **Practical applications** — specific problems solved by AI workflows

The homelab is still the laboratory. AI is just the most interesting experiment running in it.

---

## The Honest Reflection

Is this just hype? Am I chasing shiny objects?

Maybe. But here's what I keep coming back to:

**The work gets done.** Not in a "this is a fun demo" way, but in a "I genuinely rely on this daily" way. When I need to understand my storage situation, I don't open five terminal windows—I ask the Storage Manager. When I'm writing documentation, I'm not starting from blank pages—I'm reviewing AI-generated drafts.

**It compounds.** Every prompt I write, every agent I define, every MCP I build—they add to a system that keeps getting more capable. This isn't a one-time project. It's infrastructure.

**It's genuinely interesting.** I'm not even three years into my apprenticeship, but this is the thing that genuinely caught my attention and kept me hooked for days. That's rare. That's worth pursuing.

---

## Where to Find the Work

If you want to see what I've actually built:

- **[ai-prompts repository](https://github.com/Luca-Pelzer/ai-prompts)** — All 110 prompts and 28 agents, organized and documented
- **Previous posts** — The [multi-agent workflow post](/blogs/multiagent-ai-workflow/) goes deeper on the technical architecture
- **This blog** — Where I'll keep documenting what I learn

The homelab taught me to build. The AI work is teaching me to think differently about what "building" means.

And honestly? I'm having more fun than I've had in years.
