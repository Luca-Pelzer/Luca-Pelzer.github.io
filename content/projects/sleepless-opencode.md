---
title: "Sleepless OpenCode"
date: 2026-01-12
draft: false
description: "24/7 AI agent daemon that processes coding tasks while you sleep. Submit via Discord, Slack, or CLI - get notified when complete."
tags: ["OpenCode", "AI", "Discord", "Automation", "TypeScript", "Claude"]
image: "/images/projects/sleepless.svg"
github: "https://github.com/engelswtf/sleepless-opencode"
demo: ""
featured: true
weight: 0
---

A background task daemon that runs AI coding tasks 24/7, even when you close OpenCode.

## Features

- **Discord Bot**: `/task`, `/status`, `/tasks`, `/cancel` commands
- **SQLite Queue**: Persistent task queue with priority ordering (urgent/high/medium/low)
- **Discord Notifications**: Get notified when tasks start, complete, or fail
- **OpenCode Plugin**: Direct integration via `opencode-sleepless` npm package
- **CLI**: Quick task submission from terminal

## How It Works

1. Submit task via Discord: `/task Add unit tests for the auth module`
2. Daemon queues task in SQLite database
3. Spawns OpenCode session with Claude
4. Executes your prompt autonomously
5. Sends Discord notification with results

## Quick Start

```bash
git clone https://github.com/engelswtf/sleepless-opencode
cd sleepless-opencode
npm install
cp .env.example .env  # Add Discord bot token
npm run build
npm start
```

## OpenCode Plugin

```bash
npm install opencode-sleepless
```

Add to your `opencode.json`:
```json
{
  "plugin": ["opencode-sleepless"]
}
```

Then use the sleepless agent to queue tasks that run while you sleep.

## Links

- [sleepless-opencode](https://github.com/engelswtf/sleepless-opencode) - Main daemon
- [opencode-sleepless](https://github.com/engelswtf/opencode-sleepless) - OpenCode plugin
