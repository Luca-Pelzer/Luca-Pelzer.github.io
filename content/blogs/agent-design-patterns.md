---
title: "Agent Design Patterns: What Makes a Good AI Agent"
date: 2025-01-11
draft: false
tags: ["ai", "agents", "prompt-engineering", "patterns", "opencode", "automation"]
categories: ["AI", "Technical"]
description: "After building 28 specialized agents, here are the patterns that actually work. From structure to constraints to communication style - a practical guide to agent design."
---

# Agent Design Patterns: What Makes a Good AI Agent

**TL;DR**: I've built 28 agents across infrastructure, development, content, and research domains. Along the way, I discovered that the difference between a mediocre agent and a great one comes down to a few key patterns. This post breaks down what actually works.

---

## Why This Matters

You can give an AI a vague system prompt like "You are a helpful coding assistant" and it'll work... kind of. It'll be inconsistent, sometimes overstep, sometimes under-deliver, and you'll spend more time correcting it than it saves you.

Or you can invest time in proper agent design and get something that feels like a reliable team member.

After building agents for storage management, security auditing, code review, fact-checking, and more, I've landed on a pattern that works. Here's the breakdown.

---

## The Golden Standard Structure

Every good agent I've built follows this structure:

```
1. Frontmatter (metadata)
2. One-line description
3. Role definition
4. Critical Rules
5. Detailed Workflow
6. Output Templates
7. What You CAN Do
8. What You CANNOT Do
9. Communication Style
10. Integration Notes
```

Let me explain why each section matters.

---

## 1. Start with Identity, Not Instructions

Bad:
```
You are an AI assistant that helps with security.
```

Good:
```
# Security Auditor

Expert auditor of infrastructure security: firewall configuration, 
system hardening, SSH security, user accounts, and file permissions. 
Analyzes against NIST and CIS benchmarks.

**This agent is READ-ONLY** - it analyzes and reports only, never executes changes.
```

The difference? Specificity and constraints. The good version tells the agent:
- What it's an expert in (not everything)
- What frameworks it references (NIST, CIS)
- Its operational mode (read-only)

This immediately narrows scope and sets expectations.

---

## 2. Critical Rules: The Non-Negotiables

Every agent needs explicit rules it cannot break. I wrap these in a `<critical_rules>` block to make them stand out:

```markdown
<critical_rules>
- ALWAYS read ALL relevant config files before assessment
- NEVER execute any commands that modify system state
- ALWAYS categorize findings by severity (CRITICAL/HIGH/MEDIUM/LOW)
- ALWAYS provide specific file paths and line numbers for issues
- ALWAYS include remediation steps for each finding
</critical_rules>
```

Notice the pattern: every rule starts with ALWAYS or NEVER. No ambiguity.

Without these, agents will:
- Skip verification steps when they "feel confident"
- Make changes when they should only report
- Give vague answers when you need specifics

---

## 3. Workflow: Show the Process

Don't just tell an agent what to do—show it how to think through problems:

```markdown
## Audit Workflow

### 1. GATHER DATA (Read-Only)
[specific commands to run]

### 2. ANALYZE
[what to check against]

### 3. ASSESS RISKS
For each finding, document:
- **What**: The specific issue
- **Where**: File path and line number
- **Impact**: What could happen if exploited
- **Likelihood**: How probable is exploitation
- **Severity**: CRITICAL/HIGH/MEDIUM/LOW

### 4. RECOMMEND
[what to include in recommendations]

### 5. REPORT
[output format]
```

This is like giving someone a checklist. They're less likely to skip steps or invent their own (worse) process.

---

## 4. Output Templates: Be Prescriptive

One of the biggest improvements I made was adding actual output templates. Instead of hoping the agent formats things well, I show exactly what I want:

```
┌─────────────────────────────────────────────────────┐
│ VM/Container: [name] (ID: [id])                     │
├─────────────────────────────────────────────────────┤
│ Status: Running/Stopped                             │
│ Uptime: X days Y hours                              │
│ Health: 🟢/🟡/🔴                                    │
├─────────────────────────────────────────────────────┤
│ CPU:    ██████░░░░ 60% (2/4 cores)                 │
│ Memory: ████████░░ 80% (3.2/4 GB) ⚠️               │
│ Disk:   █████░░░░░ 50% (25/50 GB)                  │
└─────────────────────────────────────────────────────┘
```

When the agent sees this template, it produces consistent, scannable output every time.

---

## 5. The CAN/CANNOT Pattern

This is crucial for preventing scope creep and hallucination.

```markdown
## What You CAN Do
- Read all configuration files
- Analyze security posture
- Assess risks and severity
- Provide specific recommendations
- Reference compliance standards

## What You CANNOT Do
- Modify any configurations
- Execute remediation commands
- Restart services
- Change user accounts
- Apply fixes (reporting only)
```

Anthropic's research confirms this: explicit capability boundaries make agents more reliable. They're less likely to overpromise or attempt things outside their scope.

The key insight: be specific. "Don't do bad things" is useless. "Never execute commands that modify system state" is actionable.

---

## 6. Communication Style: Good vs Bad Examples

Agents learn from examples. I include both good and bad:



**Good (specific and actionable):**

> CRITICAL: SSH allows password authentication from any source.
> Location: /etc/ssh/sshd_config line 58
> Risk: Attackers can brute-force passwords. Your server likely receives thousands of attempts daily.
> Fix: Set 'PasswordAuthentication no' and restart sshd.
> Verify: sshd -T | grep passwordauthentication

**Bad (vague):**

> SSH could be more secure.

This single pattern eliminated most of my "the agent gave a useless response" moments. When it knows what good looks like, it produces good.


---

## 7. Integration Notes: Playing Well with Others

Agents don't work in isolation. I document how each agent complements others:

```markdown
## Integration Notes

This agent works well with:
- **VM Monitor**: For correlating security with resource usage
- **Storage Manager**: For permission and encryption checks
- **DevOps Helper**: For secure deployment configurations
```

This serves two purposes:
1. Helps me remember which agents to use together
2. Gives the agent context about the broader system

---

## Patterns That Emerged

After building 28 agents, some meta-patterns became clear:

### Specialization Beats Generalization

A "Code Review Agent" that tries to do security, performance, style, and architecture review does all of them poorly.

Instead, I have:
- Security Scanner (OWASP focus)
- Performance Reviewer
- Code Smell Detector
- API Design Reviewer

Each one goes deep on its domain.

### Tables for Reference Data

Whenever there's categorical information, I use tables:

```markdown
| Severity | Definition | Response Timeline |
|----------|------------|-------------------|
| CRITICAL | Active exploitation risk | Fix within 24 hours |
| HIGH | Significant weakness | Fix within 1 week |
| MEDIUM | Best practice deviation | Fix within 1 month |
| LOW | Minor improvement | Next maintenance |
```

Agents reference these consistently, which means consistent output.

### Checklists for Verification

Instead of trusting the agent to remember everything:

```markdown
**SSH Hardening Checklist:**
- [ ] Protocol 2 only
- [ ] PermitRootLogin no
- [ ] PasswordAuthentication no
- [ ] PubkeyAuthentication yes
- [ ] PermitEmptyPasswords no
```

The agent works through each item systematically.

---

## The Minimum Viable Agent

If you're starting out, here's the minimum structure that works:

```markdown
# [Agent Name]

[One sentence: what this agent does and its key constraint]

## Role

You are an expert in [specific domain] specializing in:
- [Specialty 1]
- [Specialty 2]
- [Specialty 3]

## Critical Rules

<critical_rules>
- ALWAYS [key behavior]
- NEVER [key constraint]
- ALWAYS [verification step]
</critical_rules>

## What You CAN Do
- [Capability 1]
- [Capability 2]

## What You CANNOT Do
- [Constraint 1]
- [Constraint 2]

## Communication Style

**Good:** [Example of ideal output]

**Bad:** [Example of what to avoid]
```

That's maybe 50 lines. Start there, then expand based on what breaks.

---

## What I Learned

1. **Invest upfront, save later**: A well-designed agent takes hours to build but saves days of frustration

2. **Explicit beats implicit**: If you want specific behavior, specify it. Models don't read minds.

3. **Templates > instructions**: Showing the output format you want works better than describing it

4. **Constraints prevent disasters**: The CANNOT section is as important as the CAN section

5. **Test with real tasks**: Build agents for actual problems you have, not theoretical ones

---

## Where to Find Examples

All 28 of my agents are open source:
- **[ai-prompts repository](https://github.com/engelswtf/ai-prompts)** - Browse the full collection

The agents are organized into packs:
- **Infrastructure** (7): Storage, monitoring, security, networking, databases
- **Development** (7): Code building, review, testing, API design, performance
- **Content** (6): Blog writing, documentation, social media, newsletters
- **Research** (8): Market research, competitive analysis, fact-checking, trends

Each one follows the golden standard pattern. Fork them, adapt them, make them yours.

---

## Next Steps

If you're building agents, start with one real problem you have. Build an agent for it using this structure. Test it. Iterate.

The patterns compound. Once you have one good agent, building the next one is faster. And when you have ten agents that work well together, you've got something that genuinely multiplies your capabilities.

That's the goal, anyway. I'm not even three years into my apprenticeship, but this is the thing that caught my attention and kept me hooked for days. There's something here.
