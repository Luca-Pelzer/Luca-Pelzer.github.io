---
title: "From CLI to SDK: Making Sleepless-OpenCode's Internal Agent Truly Invisible"
date: 2025-01-12
draft: false
tags: ["opencode", "sdk", "agents", "automation", "typescript", "sleepless-opencode"]
categories: ["AI", "Technical"]
description: "How we migrated from command-line execution to programmatic SDK calls to hide an internal agent from the UI, solving a tricky architecture problem in sleepless-opencode."
---

I was building [sleepless-opencode](https://github.com/Luca-Pelzer/sleepless-opencode), a 24/7 AI agent daemon that processes coding tasks in the background. Think of it as a task queue where you submit work via Discord, and an AI agent executes it while you sleep.

The daemon uses a specialized agent called `sleepless-executor` to run tasks. This agent is purely internal—it's not meant for direct user interaction. Users should never select it manually from the agent picker.

But there was a problem: **to work with the OpenCode CLI, the agent had to be configured as `mode: primary`, which made it visible in the UI.**

This was annoying. Every time users opened the agent picker, they'd see this internal implementation detail cluttering their interface. Not ideal.

## The Challenge: CLI Limitations

The daemon originally spawned OpenCode sessions using the CLI:

```bash
opencode run --agent sleepless-executor --session <id> -- "<prompt>"
```

This worked fine, but the OpenCode CLI has a limitation: **it only recognizes agents in `primary` mode**. Agents configured as `subagent` (which are hidden from the UI) simply don't work with CLI invocations.

So we were stuck:
- Use `mode: primary` → Agent works but appears in UI ❌
- Use `mode: subagent` → Agent hidden but CLI fails ❌

Neither option was acceptable.

## The Investigation: How Do Plugins Do It?

I started digging into how other OpenCode plugins spawn agents programmatically. Specifically, I looked at the [oh-my-opencode](https://github.com/opencode-ai/oh-my-opencode) plugin source code.

That's when I discovered the secret: **OpenCode has an official SDK** (`@opencode-ai/sdk`) that provides direct API access to session management, completely bypassing the CLI.

The SDK doesn't care about agent modes. It can spawn any agent—primary or subagent—because it talks directly to OpenCode's internal APIs.

Perfect! This was exactly what we needed.

## The Solution: Embrace the SDK

I migrated the daemon from CLI-based execution to SDK-based execution. Here's how it works:

### 1. Initialize the SDK Server

On daemon startup, we create an OpenCode SDK server:

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

### 2. Create Sessions Programmatically

Instead of spawning CLI processes, we use the SDK's `session.create()` API:

```typescript
const createResult = await client.session.create({
  body: {
    title: `Sleepless Task #${task.id}`,
  },
  query: { directory: workDir },
});

const sessionId = createResult.data.id;
```

### 3. Send Prompts to Any Agent

Here's the magic: `session.prompt()` works with **any agent**, regardless of mode:

```typescript
const promptResult = await client.session.prompt({
  path: { id: sessionId },
  body: {
    agent: "sleepless-executor",  // Works even as subagent!
    parts: [{ type: "text", text: prompt }],
  },
  query: { directory: workDir },
});
```

### 4. Poll for Completion

We poll the session status until it becomes idle:

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

### 5. Update Agent Configuration

Finally, we changed the agent mode to `subagent`:

```yaml
---
description: Internal daemon worker - do not use directly
mode: subagent  # Changed from 'primary'
model: anthropic/claude-sonnet-4-5
---
```

Done! The agent is now hidden from the UI but fully functional.

## The Benefits

This migration gave us several wins:

1. **Hidden from UI**: `sleepless-executor` no longer clutters the agent picker
2. **Programmatic control**: Full API access to session management
3. **Better integration**: Direct communication without CLI overhead
4. **Backwards compatible**: Falls back to CLI if SDK initialization fails
5. **Cleaner architecture**: No more spawning shell processes and parsing stdout

## Technical Deep Dive

The SDK provides these key APIs:

| API | Purpose |
|-----|---------|
| `session.create()` | Create new agent sessions |
| `session.prompt()` | Send prompts to sessions (works with any agent mode) |
| `session.status()` | Check if session is idle/active |
| `session.messages()` | Retrieve session messages and output |

The daemon's execution flow now looks like this:

```
1. Daemon starts → Initialize SDK server
2. Task queued → Create session via SDK
3. Send prompt → session.prompt() with agent name
4. Poll status → Wait for session.status() === "idle"
5. Extract output → session.messages() to get results
6. Notify user → Send Discord/Slack notification
```

## Lessons Learned

1. **Read the plugin source code**: When the docs don't cover your use case, dive into how existing plugins solve similar problems.

2. **SDK > CLI for programmatic use**: If you're building automation or integrations, the SDK gives you much more control and flexibility than shelling out to the CLI.

3. **Agent modes matter**: Understanding the difference between `primary` (user-facing) and `subagent` (internal) modes is crucial for building clean UIs.

4. **Always have a fallback**: Keeping the CLI execution path as a fallback ensures robustness even if the SDK has issues.

## Conclusion

This migration demonstrates the power of OpenCode's SDK for building programmatic integrations. By moving from CLI to SDK, we achieved a cleaner architecture where internal agents can remain hidden while still being fully functional.

If you're building OpenCode integrations and need programmatic agent control, skip the CLI and go straight to the SDK. Your future self (and your users) will thank you.

---

**Want to try sleepless-opencode?**

Check it out on [GitHub](https://github.com/Luca-Pelzer/sleepless-opencode).
