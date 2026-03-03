---
title: "My AI Team: How Multi-Agent Workflows Made Me Feel Like I Have Employees"
date: 2025-12-16
draft: false
tags: ["ai", "automation", "opencode", "mcp", "productivity", "homelab"]
categories: ["AI", "Automation"]
description: "I set up a multi-agent AI system that feels like managing a team of specialized employees. Here's how OpenCode, MCPs, and LSPs turned AI from a chatbot into actual infrastructure."
---

# My AI Team: How Multi-Agent Workflows Made Me Feel Like I Have Employees

**TL;DR**: I built a multi-agent AI setup using OpenCode with 11 specialized agents. Each one is an expert in their domain (code, storage, security, docs, etc.). Combined with MCPs (Model Context Protocol) and LSPs (Language Server Protocol), they can actually interact with my systems. It genuinely feels like delegating to a team instead of doing everything myself.

---

## The Problem: Being a One-Person IT Department

You know what sucks? Being the only person responsible for everything.

I run a homelab with:
- Proxmox cluster with 10+ VMs and containers
- Mail server, DNS, reverse proxy, monitoring
- Multiple web apps and services
- Storage management with LVM and thin provisioning
- Firewall rules, security hardening, backups
- Documentation that's always out of date

Every time something breaks, I'm the one who fixes it. Every time I want to add a feature, I'm the one who codes it. Every time I need documentation, I'm the one who writes it.

**Context switching is exhausting.**

One minute I'm debugging Python. The next I'm analyzing Shorewall firewall rules. Then I'm writing LVM commands. Then I'm updating documentation. Then I'm back to Python but I've completely forgotten what I was doing.

I tried keeping notes. I tried better organization. I tried just accepting that I'd forget everything and re-learn it each time.

Then I discovered something that actually worked: **multi-agent AI workflows.**

---

## The Solution: An AI Team

Here's the setup I built using [OpenCode](https://github.com/sst/opencode):

### The Team

| Agent | Role | Model | What They Do |
|-------|------|-------|--------------|
| **Orchestrator** | Manager | Claude Opus | Routes tasks to the right specialist |
| **Code-Builder** | Developer | Claude Opus | Python, Node.js, Go development |
| **Storage-Manager** | SysAdmin | Claude Sonnet | LVM, backups, Proxmox storage |
| **Firewall-Auditor** | Security Analyst | Claude Sonnet | Shorewall analysis (read-only) |
| **Security-Auditor** | Security Engineer | Claude Opus | SSH hardening, compliance |
| **VM-Monitor** | Operations | Claude Haiku | Container/VM health checks |
| **Research-Agent** | Researcher | Claude Sonnet | Gathering info, best practices |
| **Writer-Agent** | Technical Writer | Claude Opus | Documentation, guides, tutorials |
| **DevOps-Helper** | DevOps Engineer | Claude Sonnet | Docker, CI/CD, deployment |
| **Docs-Keeper** | Librarian | Claude Haiku | Maintaining runbooks, archiving |
| **Agent-Creator** | Meta-Agent | Claude Opus | Creates new agents (!) |

Each agent has:
- **Specialized knowledge** in their domain
- **Specific tools** they can use (via MCPs)
- **Clear responsibilities** and boundaries
- **Different models** based on task complexity

---

## The Game Changer: MCPs and LSPs

Here's where it gets wild. These aren't just chatbots that generate text. They can actually **do things.**

### MCPs (Model Context Protocol)

Think of MCPs as "tools that let AI interact with real systems." Instead of just talking about what to do, agents can actually execute commands and get real data.

I built custom MCP servers for my infrastructure:

**Proxmox MCP** - Manage my virtualization cluster
```typescript
// The AI can actually query my Proxmox cluster
tools: [
  "proxmox_list_containers",      // List all VMs and containers
  "proxmox_container_status",     // Check if a container is running
  "proxmox_storage_status",       // See storage pool usage
  "proxmox_node_status"           // Get CPU, RAM, uptime
]
```

**Storage MCP** - Direct access to storage systems
```typescript
// Direct access to LVM commands
tools: [
  "storage_vg_status",      // Volume group info
  "storage_lv_status",      // Logical volume details
  "storage_disk_usage",     // Filesystem usage (df -h)
  "storage_smart_status",   // Disk health data
  "storage_thin_pool_status" // Thin provisioning metrics
]
```

**Shorewall MCP** - Firewall analysis (read-only for safety)
```typescript
// Firewall analysis (read-only for safety)
tools: [
  "shorewall_status",           // Is firewall running?
  "shorewall_list_rules",       // All firewall rules
  "shorewall_security_audit",   // Automated security check
  "shorewall_list_zones"        // Network zones
]
```

**Discord MCP** - Manage Discord servers programmatically
```typescript
// Manage Discord servers
tools: [
  "discord_list_servers",       // All servers bot has access to
  "discord_create_channel",     // Create new channels
  "discord_send_message",       // Send messages
  "discord_create_role"         // Manage permissions
]
```

**Docmost MCP** - Publish documentation to my wiki
```typescript
// Documentation platform integration
tools: [
  "docmost_create_page",        // Create new wiki pages
  "docmost_update_page",        // Update existing docs
  "docmost_search",             // Search documentation
  "docmost_list_pages"          // Browse all pages
]
```

Now when I ask "check my firewall security," the Firewall-Auditor agent:
1. Uses the Shorewall MCP to read current rules
2. Analyzes them for common vulnerabilities
3. Generates a detailed report
4. Suggests specific improvements

**It's not generating fake commands. It's running real ones.**

### LSPs (Language Server Protocol)

LSPs give AI agents code intelligence. The same technology that powers VS Code autocomplete now powers my AI agents.

When Code-Builder writes Python:
- ✅ Real-time syntax checking
- ✅ Import resolution (knows what libraries are installed)
- ✅ Type checking (catches type errors before running)
- ✅ Go-to-definition (understands code structure)
- ✅ Error detection (finds bugs as it writes)

The code it generates actually works because it has the same intelligence as a human developer using an IDE.

---

## The Meta Moment: An Agent That Creates Agents

Here's where I had a "wait, this is insane" moment.

I was manually creating new agents by writing prompt files. Then I thought: **Why can't an agent do this?**

So I created **Agent-Creator**, an agent whose entire job is to create other agents.

Now when I need a new specialist:

```
Me: "I need an agent for managing my mail server"

Agent-Creator:
- Analyzes what the agent needs to know (Postfix, Dovecot, DNS)
- Chooses the appropriate model (Sonnet for standard ops)
- Writes the prompt file with specialized knowledge
- Configures the tools/MCPs it needs (mail server MCP)
- Creates the agent config
- Tests that it works
- Reports back: "Mail-Manager agent created and ready"

Me: *does nothing*
```

**The system is self-improving.** I can delegate the creation of delegation tools. It's turtles all the way down.

---

## Model Selection: The Secret Sauce

One of my biggest realizations: **not every task needs the most powerful model.**

### Cost Optimization Strategy

| Task Complexity | Model | Use Case | Cost |
|----------------|-------|----------|------|
| Complex reasoning | Claude Opus | Architecture decisions, debugging | $$$ |
| Standard tasks | Claude Sonnet | Most development, analysis | $$ |
| Simple operations | Claude Haiku | Health checks, simple queries | $ |

**Example workflow:**
1. **Orchestrator** (Opus) routes the task → $$$
2. **VM-Monitor** (Haiku) checks container status → $
3. **Storage-Manager** (Sonnet) analyzes disk usage → $$
4. **Writer-Agent** (Opus) documents the findings → $$$

Total cost: Way less than using Opus for everything.

The Orchestrator is the only agent that *always* uses Opus, because routing decisions are critical. Everything else is optimized.

**My recommendation**: Get the Claude Max subscription (€100/month). You get 5x more usage on all models (resets every ~5 hours). There's also a €200/month tier that gives you 20x more on everything. No more worrying about API costs or running out of credits mid-project. If you're serious about using AI as a productivity tool, the subscription pays for itself in the first week.





---

## Getting Started (Even If You've Never Done This Before)

Okay, enough theory. Let's build this thing. I'm going to walk you through this like you're my friend who's never touched a command line before.

### Prerequisites

You need:
- **A computer** (Mac, Linux, or Windows with WSL)
- **A Claude subscription** (I use Claude Max at €100/month - highly recommended if you're serious about this)

- **10 minutes of your time**

### Step 1: Install OpenCode

Open your terminal and run:

```bash
# Install OpenCode globally
npm install -g opencode

# Or use npx (no installation needed)
npx opencode@latest
```

**What you'll see:**
```
✓ OpenCode installed successfully
✓ Creating .opencode directory
✓ Setting up configuration
```

### Step 2: First Run and Connect Your Account

Start OpenCode:

```bash
opencode
```

OpenCode will open in your terminal. The first thing you need to do is connect your Claude account:

```
/connect
```

This will open a browser window where you can log in with your Anthropic/Claude account. Once authenticated, you're ready to go!

> **Pro tip**: You can use any model via the API directly or through providers like OpenRouter, but Claude is the most cost-effective for this workflow. I use the Claude Max subscription (€100/month) instead of API credits - if you're going to use this seriously, the subscription is way more cost-effective and you don't have to worry about running out of credits mid-task.


### Step 3: Create Your First Agent

Let's create a simple agent. We'll make a "System-Monitor" that checks your computer's health.

Create a file at `~/.opencode/agents/system-monitor.md`:

```bash
# Create the agents directory if it doesn't exist
mkdir -p ~/.opencode/agents

# Create your first agent
cat > ~/.opencode/agents/system-monitor.md << 'EOF'
---
name: system-monitor
description: Monitors system health and resource usage
model: anthropic/claude-haiku-4-20250514
mode: subagent
---

# System Monitor

You are a system monitoring specialist. Your job is to check system health and report issues.

## Your Capabilities

You can check:
- CPU usage
- Memory usage
- Disk space
- Running processes
- System uptime

## Rules

- ALWAYS provide specific numbers (percentages, GB used, etc.)
- NEVER make assumptions - check actual current state
- WARN if disk usage is above 80%
- WARN if memory usage is above 90%
- Keep responses concise and actionable

## Response Format

When checking system health:
1. **Status**: Overall health (Good/Warning/Critical)
2. **Details**: Specific metrics
3. **Issues**: Any problems found
4. **Recommendations**: What to do about issues
EOF
```

**Test your agent:**

```bash
opencode

> @system-monitor check system health
```

**What you'll see:**
```
System Monitor: Checking system health...

Status: Good
Details:
- CPU: 15% usage
- Memory: 8.2GB / 16GB (51%)
- Disk: 120GB / 500GB (24%)
- Uptime: 5 days

Issues: None
Recommendations: System is healthy
```

### Step 4: Add Your First MCP (Optional but Cool)

MCPs let agents interact with external systems. Let's add a simple one.

**Create a simple MCP for system commands:**

```bash
# Create MCP directory
mkdir -p ~/.opencode/mcp-servers/system

# Create a basic MCP server
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

// Define available tools
server.setRequestHandler("tools/list", async () => ({
  tools: [
    {
      name: "system_disk_usage",
      description: "Get disk usage for all mounted filesystems",
      inputSchema: {
        type: "object",
        properties: {}
      }
    },
    {
      name: "system_memory_usage",
      description: "Get current memory usage",
      inputSchema: {
        type: "object",
        properties: {}
      }
    }
  ]
}));

// Handle tool calls
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

// Start server
const transport = new StdioServerTransport();
await server.connect(transport);
EOF

# Install dependencies
cd ~/.opencode/mcp-servers/system
npm init -y
npm install @modelcontextprotocol/sdk
```

**Configure OpenCode to use your MCP:**

Edit `~/.opencode/opencode.json` and add:

```json
{
  "mcp": {
    "system": {
      "command": ["node", "/home/YOUR_USERNAME/.opencode/mcp-servers/system/index.js"],
      "enabled": true,
      "description": "System monitoring tools"
    }
  }
}
```

**Update your agent to use the MCP:**

Edit `~/.opencode/agents/system-monitor.md` and add:

```markdown
## Your Tools

You have access to these MCP tools:
- system_disk_usage - Get disk usage for all filesystems
- system_memory_usage - Get current memory usage

Use these tools to get real-time system data.
```

**Test it:**

```bash
opencode

> @system-monitor check disk usage using your tools
```

Now your agent can actually query your system!

### Step 5: Create the Orchestrator

The orchestrator is the "manager" that routes tasks to the right agent.

```bash
cat > ~/.opencode/agents/orchestrator.md << 'EOF'
---
name: orchestrator
description: Routes tasks to specialized agents
model: anthropic/claude-opus-4-20250514
mode: primary
---

# Orchestrator

You are the orchestrator. Your job is to route tasks to the right specialist agent.

## Available Agents

- **system-monitor**: System health, resource usage, disk space

## Rules

- ALWAYS route tasks to the appropriate specialist
- NEVER try to do specialized work yourself
- Use @ mentions to delegate: @system-monitor
- Explain why you're routing to that agent

## Response Format

When receiving a task:
1. Identify which agent should handle it
2. Explain your routing decision
3. Delegate with @mention
EOF
```

**Test the orchestrator:**

```bash
opencode

> @orchestrator I need to check if my system is healthy
```

**What you'll see:**
```
Orchestrator: This is a system health check task. 
Routing to @system-monitor as they specialize in system monitoring.

@system-monitor check system health
```

Congratulations! You now have a working multi-agent system!

---

## How It Actually Feels to Use

### Before: Solo Suffering

```
Me: *needs to check firewall, analyze storage, update docs*
Me: *opens 5 terminal windows*
Me: *forgets what I was doing*
Me: *spends 2 hours context switching*
Me: *accomplishes one thing*
```

### After: Delegation

```
Me: "Check my firewall security and document any issues"

Orchestrator: "Routing to Firewall-Auditor and Writer-Agent"

Firewall-Auditor:
- Runs security audit via Shorewall MCP
- Finds 3 potential issues
- Generates detailed report

Writer-Agent:
- Creates documentation page
- Publishes to Docmost wiki
- Provides link

Me: *reads the report, makes coffee*
```

**It genuinely feels like having employees.**

I delegate. They do the work. They report back. I make decisions.

---

## Real-World Examples

### Example 1: Security Audit

```
Me: "Audit my SSH security and firewall rules"

Orchestrator: Routes to Security-Auditor and Firewall-Auditor

Security-Auditor:
✓ Checks SSH config
✓ Verifies key-based auth is enforced
✓ Confirms root login is disabled
✓ Checks fail2ban status
✗ Found: Password auth still enabled on port 2222

Firewall-Auditor:
✓ Analyzes all Shorewall rules
✓ Checks for common misconfigurations
✗ Found: Port 3306 (MySQL) exposed to internet
✗ Found: No rate limiting on SSH

Writer-Agent:
✓ Documents findings
✓ Publishes to Docmost
✓ Provides remediation steps
```

**Result**: Detailed security report in 30 seconds. Would have taken me an hour to do manually.

### Example 2: Storage Emergency

```
Me: "My root filesystem is at 95% capacity"

Orchestrator: Routes to Storage-Manager

Storage-Manager:
✓ Checks disk usage (df -h)
✓ Finds largest directories (du -sh /*)
✓ Identifies /var/log/journal using 40GB
✓ Checks journal config
✓ Provides cleanup commands

Suggested fix:
journalctl --vacuum-size=1G
systemctl restart systemd-journald

Expected result: Frees ~39GB
```

**Result**: Problem diagnosed and solved in under a minute.

### Example 3: Documentation Sprint

```
Me: "Document my entire Proxmox setup"

Orchestrator: Routes to VM-Monitor, Storage-Manager, Writer-Agent

VM-Monitor:
✓ Lists all containers and VMs
✓ Gets resource allocation
✓ Checks running status

Storage-Manager:
✓ Documents storage pools
✓ Lists LVM configuration
✓ Maps storage to containers

Writer-Agent:
✓ Creates comprehensive documentation
✓ Includes architecture diagram (text)
✓ Documents each service
✓ Publishes to Docmost wiki
```

**Result**: Complete infrastructure documentation that would have taken me days.

---

## Advanced: Building Custom MCPs

Want to connect your agents to your own systems? Here's how to build a custom MCP.

### Example: GitHub MCP

Let's build an MCP that lets agents interact with GitHub:

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
      description: "List all repositories for the authenticated user",
      inputSchema: { type: "object", properties: {} }
    },
    {
      name: "github_create_issue",
      description: "Create a new issue in a repository",
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
        text: `Issue created: ${data.html_url}` 
      }] 
    };
  }
});

const transport = new StdioServerTransport();
await server.connect(transport);
```

Now your agents can create GitHub issues, list repos, and more!

---

## Mistakes I Made (So You Don't Have To)

### 1. Using Opus for Everything

My first setup used Claude Opus for all agents. My API bill was... concerning.

**Fix**: Match model to task complexity. Haiku for simple stuff, Sonnet for most things, Opus for complex reasoning.

**Lesson**: Not every task needs the nuclear option.

### 2. Giving Agents Too Much Power

I initially gave agents write access to production systems. Bad idea. An agent once tried to "optimize" my firewall by removing all rules.

**Fix**: Read-only MCPs for analysis. Agents suggest commands, I execute them. (Except for non-destructive operations like documentation.)

**Lesson**: Trust, but verify. And maybe don't let AI delete your firewall.

### 3. Vague Agent Prompts

"You are a helpful assistant for storage" → useless responses.

**Fix**: Specific capabilities, clear rules, exact response formats. The more detailed the prompt, the better the agent performs.

**Example of bad prompt:**
```markdown
# Storage Helper
You help with storage stuff.
```

**Example of good prompt:**
```markdown
# Storage Manager

You are an expert in Linux storage management.

## Capabilities
- LVM (volume groups, logical volumes, thin provisioning)
- Filesystem management (ext4, xfs, btrfs)
- Disk health monitoring (SMART)
- Backup strategies

## Rules
- ALWAYS check current state before recommendations
- NEVER suggest destructive operations without confirmation
- ALWAYS explain impact of changes
- Provide exact commands with expected output

## Response Format
1. Current state
2. Issues found
3. Recommendations
4. Commands to execute
5. Expected outcome
```

### 4. No Orchestrator

I tried talking to agents directly. Spent half my time figuring out which agent to use.

**Fix**: Orchestrator agent that routes tasks. I just describe what I want, it figures out who should handle it.

**Lesson**: Even AI teams need a manager.

### 5. Forgetting to Document Agent Capabilities

Created 8 agents, forgot what half of them did.

**Fix**: Each agent has a clear description and capability list. The Orchestrator reads these to make routing decisions.

**Lesson**: Documentation matters, even for AI.

### 6. Not Testing MCPs Independently

Built an MCP, integrated it with agents, nothing worked. Spent hours debugging.

**Fix**: Test MCPs standalone first:

```bash
# Test MCP directly
echo '{"jsonrpc":"2.0","method":"tools/list","id":1}' | node your-mcp.js
```

**Lesson**: Test components in isolation before integration.

### 7. Ignoring Error Messages

Agent kept failing silently. Turns out the MCP was crashing.

**Fix**: Check MCP logs:

```bash
# Run OpenCode with debug logging
DEBUG=* opencode
```

**Lesson**: Read the error messages. They're usually helpful.

---

## The "Employees" Feeling

Here's what makes this feel like managing a team:

### Specialization
Each agent is an expert in their domain. I don't need to remember LVM commands—Storage-Manager knows them.

### Delegation
I describe the outcome I want, not the steps to get there. "Check my firewall security" vs "run shorewall show rules and analyze the output for..."

### Parallel Work
Multiple agents can work simultaneously. While Firewall-Auditor checks security, Storage-Manager analyzes disk usage, and Writer-Agent documents findings.

### Consistency
Agents don't forget. They don't have bad days. They don't get tired. Every interaction is their best work.

### Documentation Happens Automatically
Writer-Agent and Docs-Keeper ensure everything gets documented. No more "I'll document this later" (narrator: he never did).

### They Actually Learn (Sort Of)
With memory MCPs, agents can remember context across conversations. Storage-Manager remembers my LVM setup. Security-Auditor remembers my security policies.

---

## Was It Worth It?

**Absolutely.**

**Setup time**: ~2 days to build the initial system
**Time saved per week**: ~10 hours
**Reduction in context switching**: ~80%
**Increase in documentation quality**: Immeasurable
**Reduction in "oh crap I forgot how to do this"**: 95%

But the real value isn't time saved. It's **cognitive load reduced.**

I don't have to remember everything anymore. I don't have to be an expert in 12 different domains. I don't have to context switch constantly.

I just describe what I need, and my "team" handles it.

**Things I can now do that I couldn't before:**
- Security audits that actually happen (instead of "I'll do it later")
- Documentation that stays up to date
- Proactive monitoring instead of reactive firefighting
- Experimenting with new tech without fear of forgetting how it works

---

## What's Next?

I'm planning to add:
- **Monitoring-Agent**: Proactive alerts for system issues
- **Backup-Agent**: Automated backup verification and testing
- **Network-Agent**: Network analysis and optimization
- **Cost-Agent**: Track and optimize cloud/API costs
- **Learning-Agent**: Analyzes my patterns and suggests improvements

And because I have Agent-Creator, I can just ask it to build these for me.

---

## Resources and Links

**OpenCode**: https://github.com/sst/opencode
**MCP Servers**: https://github.com/modelcontextprotocol/servers
**Anthropic API**: https://console.anthropic.com
**My MCP Collection**: (I should probably open-source this...)

**Community:**
- OpenCode Discord: [Join here](https://discord.gg/opencode)
- MCP Registry: [Browse MCPs](https://github.com/modelcontextprotocol/servers)

---

## Try It Yourself

The barrier to entry is surprisingly low:
1. Install OpenCode (`npm install -g opencode`)
2. Create one agent (copy the system-monitor example above)
3. Add one MCP (optional, but cool)
4. Start delegating

You don't need 11 agents to start. Begin with one specialist for your most annoying task.

For me, that was storage management. For you, it might be something else.

**Start small:**
- Day 1: Install OpenCode, create one agent
- Day 2: Test it, refine the prompt
- Day 3: Add an MCP if you're feeling adventurous
- Day 4: Create a second agent
- Day 5: Add an orchestrator to route between them

By the end of the week, you'll have a working multi-agent system.

---

## Final Thoughts

A year ago, if you told me I'd feel like I have a team of employees powered by AI, I would have laughed.

But here we are.

I delegate tasks. They get done. I review the results. I make decisions.

**It's not about replacing human work—it's about augmenting it.**

I'm still the architect. I still make the decisions. I still write the critical code.

But now I have a team that handles the grunt work, remembers the details, and keeps everything documented.

And honestly? It's the most productive I've ever been.

**The future is weird:**
- I have AI employees
- They're better at some things than I am
- They never complain
- They work 24/7
- They cost less than coffee

Now if you'll excuse me, I need to ask @storage-manager why my thin pool is at 87% capacity.

---

*P.S. - Yes, @writer-agent helped me write this blog post. Meta enough for you?*

*P.P.S. - If you build something cool with this, let me know. I'd love to see what you create.*

*P.P.P.S. - No, the agents haven't become sentient. Yet.*
