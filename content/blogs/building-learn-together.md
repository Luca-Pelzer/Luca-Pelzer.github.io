---
title: "Building LearnTogether: Because Studying Alone is Boring"
date: 2025-12-16
draft: false
tags: ["nextjs", "typescript", "socket.io", "multiplayer", "education", "project", "exam-prep"]
categories: ["Projects", "Development"]
description: "How I built a real-time multiplayer learning platform for German IT exam preparation, complete with duels, races, and way too many flashcards."
---

# Building LearnTogether: Because Studying Alone is Boring

**TL;DR**: I'm preparing for the German IT apprenticeship exam (Fachinformatiker IHK), got bored studying from PDFs, and built a multiplayer learning app instead. It has flashcards, quizzes, duels, races, and a realistic exam simulator. Productive procrastination at its finest. Try it at [learn.engels.wtf](https://learn.engels.wtf).

---

## The Problem: Death by PDF

You know what's incredibly boring? Studying for an exam by reading the same PDF for the 47th time.

I'm currently preparing for the German IT apprenticeship exam (Fachinformatiker für Systemintegration), and let me tell you—the official study materials are about as exciting as watching paint dry. On a beige wall. In a windowless room.

I tried:
- Reading PDFs (fell asleep)
- Making paper flashcards (lost them)
- Using Anki (too ugly, fight me)
- Studying with friends (we just ended up talking about everything except the exam)

Then I had a thought: **What if studying was actually... fun?**

And what if I could compete with friends instead of suffering alone?

> **Productivity tip**: If you're procrastinating on studying, just build an entire learning platform instead. That counts as studying, right? Right?

---

## What I Built

**LearnTogether** is a full-stack multiplayer learning app with 5 game modes:

### 🃏 Flashcards (Solo)
Classic flip cards. Click to reveal, mark as "Got it" or "Need practice." The app remembers which cards you struggle with so you can review them later.

### ❓ Quiz (Solo)  
Multiple choice questions with immediate feedback. Get it wrong? Here's an explanation. Get it right? Dopamine hit.

### ⚔️ Duel (Multiplayer, 2-4 players)
This is where it gets spicy. Everyone sees the same question, has 20 seconds to answer. Points for correct answers, bonus for speed. It's turn-based so everyone participates—no hiding in the back of the class.

### 🏁 Race (Multiplayer, 2-4 players)
First correct answer wins the round. But here's the twist: **if you answer wrong, you're locked out for that question.** High risk, high reward. Friendships have been tested.

### 📝 Prüfung/Exam Mode (Solo)
The crown jewel. A realistic IHK exam simulation with:
- 7 different question types (multiple choice, matching, ordering, fill-in-blank, calculations...)
- 90-minute timer (just like the real thing)
- German grading system (1-6 scale, where 1 is best)
- Detailed results breakdown

I may have spent more time building this than actually studying. No regrets.

---

## The Tech Stack

- **Next.js 14** with App Router
- **TypeScript** (because I like my errors at compile time, not at 2 AM)
- **Tailwind CSS** for styling (dark mode by default, obviously)
- **Socket.io** for real-time multiplayer
- **PM2** for process management
- **Caddy** as reverse proxy

### Why Socket.io?

For multiplayer to feel snappy, you need real-time bidirectional communication. When Player A answers, Player B needs to see it *instantly*. HTTP polling would feel sluggish.

Socket.io handles:
- Room-based game sessions (each game gets a unique room)
- Event-driven updates (answer submitted → broadcast to all players)
- Automatic reconnection (because WiFi is unreliable)
- Graceful fallback to long-polling if WebSockets fail

The server is the source of truth for game state. No cheating by inspecting the client!

---

## Interesting Challenges I Solved

### 1. Server-Synced Progress

I wanted progress to persist across devices. Log in on your phone, continue on your laptop.

Solution: Save progress to JSON files on the server, keyed by player name.

```typescript
// Simple but effective
const progressPath = path.join(DATA_DIR, `${playerName}.json`);
await fs.writeFile(progressPath, JSON.stringify(progress, null, 2));
```

No database needed at this scale. Just files. Sometimes simple is better.

### 2. Weak Cards Tracking

The app tracks cards you mark as "Need practice" and offers a dedicated review mode. This is basically spaced repetition lite—focus on what you don't know instead of reviewing stuff you've already mastered.

I have way more "weak cards" than I'd like to admit.

### 3. Multiplayer State Management

Managing game state across multiple clients is tricky. Race conditions are real when 4 people answer simultaneously.

Solution: Centralize everything on the server.

```typescript
socket.on('answer', ({ answer }) => {
  const game = games.get(roomId);
  game.answers.set(socket.id, answer);
  
  // Only proceed when everyone has answered
  if (game.answers.size === game.players.length) {
    const results = calculateScores(game);
    io.to(roomId).emit('roundResult', results);
  }
});
```

The server waits for all answers, calculates scores, then broadcasts results. No client-side score manipulation possible.

### 4. Seven Question Types for Exam Mode

The real IHK exam has various question formats. I implemented:

| Type | Input | Scoring |
|------|-------|---------|
| Multiple Choice | Radio buttons | All or nothing |
| Multiple Select | Checkboxes | Partial credit |
| Fill in the Blank | Text input | Fuzzy matching |
| Matching | Drag-and-drop pairs | Per-pair scoring |
| Ordering | Drag to reorder | Sequence matching |
| Calculation | Number input | Tolerance-based |
| Open Text | Textarea | Keyword matching |

Each type has its own React component and scoring logic. The matching and ordering ones were particularly fun to build with drag-and-drop.

---

## Content: The Actual Learning Part

I created content for 3 topics relevant to my exam:

| Topic | Flashcards | Quiz | Exam |
|-------|------------|------|------|
| 💾 Speichersysteme & Backup | 35 | 35 | 20 |
| ☁️ Cloud Computing | 32 | 24 | - |
| 🐳 Virtualisierung & Container | 40 | 22 | - |

That's **107 flashcards**, **81 quiz questions**, and **20 exam questions** with detailed explanations.

Writing all this content was honestly the most time-consuming part. But hey, writing explanations for why RAID 5 needs at least 3 disks definitely helped me understand it better.

---

## Deployment

The app runs in an LXC container on my Proxmox homelab:

```bash
# Build the Next.js app
npm run build

# Start with PM2 for process management
pm2 start ecosystem.config.js

# Caddy handles HTTPS on the host
# learn.engels.wtf → reverse proxy to container
```

It's been running stable for days now. PM2 restarts it automatically if it crashes (it hasn't).

---

## Mistakes I Made (So You Don't Have To)

### 1. Forgot to Reset Scores on Rematch
First version: Start a new duel, and you'd have your score from the last game. Oops.

### 2. Client-Side Shuffling
Initially shuffled questions on the client. Problem: In multiplayer, everyone got different question orders. Now the server shuffles once and sends the same order to everyone.

### 3. Progress Only Saved on Completion
Users would do 30 flashcards, close the tab, lose everything. Now it saves after every single card/question.

### 4. No Loading States
Socket.io connections take a moment. Without loading states, users would see a blank screen and think it was broken.

### 5. Hardcoded Localhost URLs
Worked great on my machine. Didn't work at all in production. Classic.

---

## What I Learned

1. **Socket.io is powerful but needs careful state management** — Race conditions are real when multiple clients interact simultaneously.

2. **TypeScript saves debugging time** — Especially with complex game state objects. The compiler catches so many mistakes.

3. **Incremental saves are important** — Don't wait until the user finishes to save progress. Save after each action.

4. **Dark mode first** — It's 2025. Default to dark mode. Your users' eyes will thank you.

5. **Multiplayer is addictive** — My friends and I have been dueling way more than we should be. Is this studying? Technically yes.

---

## Was It Worth It?

**Absolutely.**

Did I spend more time building this than I would have spent just studying normally? Probably.

But now I have:
- A tool I actually *want* to use
- Better understanding of the material (from writing all those explanations)
- A fun way to study with friends
- Another project for my portfolio
- This blog post

And honestly? The duels are genuinely fun. Nothing motivates you to learn like the threat of losing to your friends.

---

## Try It Out

The app is live at **[learn.engels.wtf](https://learn.engels.wtf)**

Just enter a name and start learning. No account needed, progress saves automatically.

Source code: [github.com/Luca-Pelzer/learn-together](https://github.com/Luca-Pelzer/learn-together)

---

*Now if you'll excuse me, I have an exam to study for. Or maybe I'll just add one more feature first...*
