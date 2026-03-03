---
title: "When Your Server Lags Only When You're Not Watching: Fixing IRQ Imbalance"
date: 2025-12-11
draft: false
tags: ["proxmox", "networking", "performance-tuning", "debugging", "linux", "irq-balance", "homelab"]
categories: ["Homelab", "Performance", "Tutorials"]
description: "Mysterious network lag that disappeared when monitoring started? It was IRQ imbalance - all network interrupts on one CPU core. Here's how to diagnose and fix it."
---

# When Your Server Lags Only When You're Not Watching: Fixing IRQ Imbalance

**TL;DR**: My Proxmox server had mysterious network lag that disappeared the moment I opened `htop` to investigate. Turned out all network interrupts were being handled by a single CPU core. After enabling `irqbalance`, tuning RPS, and adjusting network buffers, the lag vanished for good. Here's how to diagnose and fix IRQ imbalance on your own server.

---

## The Observer Effect Bug

You know that feeling when your car makes a weird noise for weeks, but the moment you drive it to the mechanic, it runs perfectly? That was my Proxmox server last month.

**The symptoms:**
- Random network lag spikes (200-500ms ping jumps)
- Container web services occasionally timing out
- SSH sessions freezing for 2-3 seconds randomly
- **The kicker:** The moment I SSH'd in and ran `htop` or opened Netdata, everything ran smoothly

This is the most frustrating kind of bug - one that hides when you try to observe it. Schrödinger's lag, if you will.

> 💡 **Spoiler**: This isn't magic. When you run monitoring tools, they spin up processes on different CPU cores, which temporarily shifts the workload and gives the overloaded core a moment to catch up. It's like unclogging a drain by running water through a different pipe.

## Prerequisites

Before we dive in, you'll need:
- A Linux server (I'm using Proxmox, but this applies to any Debian/Ubuntu-based system)
- Root access
- Basic familiarity with the command line
- About 30 minutes for diagnostics and fixes
- Patience (some of this involves watching counters tick up)

**Knowledge level:** Intermediate - I'll explain concepts, but you should be comfortable with SSH and editing system files.

---

## Step 1: Security Check First

When weird performance issues show up out of nowhere, my first thought is always: **"Did someone break in?"**

Before optimizing anything, I checked for:

```bash
# Check for suspicious processes
ps aux | grep -iE 'xmr|crypto|mine' 

# Look for unauthorized SSH keys
cat ~/.ssh/authorized_keys
find /home -name authorized_keys -exec cat {} \;

# Check for rootkits
apt install -y chkrootkit rkhunter
chkrootkit
rkhunter --check --skip-keypress

# Review running network connections
netstat -tulpn | grep ESTABLISHED

# Check cron jobs for weird stuff
crontab -l
cat /etc/cron.d/*
```

Everything came back clean. No crypto miners, no suspicious processes, no unauthorized access. Good, but now I had to actually debug the real problem.

> ⚠️ **Warning**: Never skip this step. Performance issues can be symptoms of compromise. Always rule out security issues before assuming it's just a configuration problem.

---

## Step 2: Discovering the IRQ Imbalance

After ruling out malware, I started looking at resource distribution. First stop: interrupts.

### What are IRQs anyway?

**IRQ (Interrupt Request)** is how hardware devices (like your network card) get the CPU's attention. When a network packet arrives, the NIC says "Hey CPU, I got something for you!" via an interrupt.

Normally, these interrupts should be distributed across all CPU cores. But let's check:

```bash
# Watch interrupt distribution in real-time
watch -n 2 'cat /proc/interrupts | grep -E "CPU|eth0|eno1|enp"'
```

> 💡 **Tip**: Replace `eth0` or `eno1` with your actual network interface name. Find it with `ip link show`.

Here's what I saw:

```
           CPU0   CPU1   CPU2   CPU3   CPU4   CPU5   ...
eth0-TxRx  3301245    0      0      0      0      0   ...
```

**Yikes.** All 3.3 million interrupts on CPU0 only. Every single network packet being handled by one core while the other 11 cores sat idle like they were on break.

### Checking softirqs

Interrupts have a two-phase handling:
1. **Hard IRQ**: "Hey, packet arrived!" (handled immediately)
2. **Soft IRQ**: "Let me process that packet" (scheduled work)

Let's check the softirq distribution:

```bash
watch -n 2 'cat /proc/softirqs | grep -E "CPU|NET_RX"'
```

```
          CPU0      CPU1      CPU2      CPU3    ...
NET_RX:   8504321   850432    823012    801234  ...
```

CPU0 was handling **10x more** receive softirqs than other cores. This was the smoking gun.

### Why monitoring "fixed" it

When I opened `htop`, it would:
1. Spawn processes on available CPU cores
2. Trigger kernel scheduler activity
3. Temporarily shift some workload away from CPU0
4. Give CPU0 breathing room to process its backlog

The lag wasn't actually "fixed" - it was just masked temporarily. Like putting a band-aid on a broken pipe.

---

## Step 3: The Fix (Multiple Layers)

IRQ imbalance isn't fixed with one magic command. It's a stack of improvements:

### Layer 1: Install irqbalance

This daemon automatically distributes interrupts across CPU cores:

```bash
# Install and enable
apt install -y irqbalance
systemctl enable --now irqbalance

# Verify it's running
systemctl status irqbalance
```

Within 10 seconds, I saw interrupts spreading across cores:

```
           CPU0   CPU1   CPU2   CPU3   CPU4   CPU5   ...
eth0-TxRx  3301245  1203   2104   1832   2411   1937  ...
```

Much better! But we're not done.

### Layer 2: Enable RPS (Receive Packet Steering)

RPS is like power steering for network packets - it helps distribute packet processing across CPU cores at the software level.

```bash
# Find your interface name
ip link show

# Enable RPS for all CPUs (adjust the hex value based on your CPU count)
# fff = 12 CPUs in hex (111111111111 in binary)
# For 4 CPUs use 'f', for 8 use 'ff', for 16 use 'ffff'
echo "fff" > /sys/class/net/eth0/queues/rx-0/rps_cpus

# Verify
cat /sys/class/net/eth0/queues/rx-0/rps_cpus
```

**How to calculate your RPS mask:**
- Count your CPU cores: `nproc`
- Convert to hex: 4 CPUs = `f`, 8 = `ff`, 12 = `fff`, 16 = `ffff`
- The mask is a bitmask where each bit represents a CPU

### Layer 3: Increase NIC Ring Buffers

The NIC's ring buffer is like a waiting room for packets. Mine was tiny:

```bash
# Check current size
ethtool -g eth0
```

```
Ring parameters for eth0:
Pre-set maximums:
RX:     4096
TX:     4096
Current hardware settings:
RX:     256    # Way too small!
TX:     256
```

```bash
# Increase to maximum
ethtool -G eth0 rx 4096 tx 4096

# Verify
ethtool -g eth0
```

### Layer 4: Tune Network Stack (sysctl)

Create `/etc/sysctl.d/99-network-tuning.conf`:

```bash
# Increase socket buffer sizes (128MB)
net.core.rmem_max = 134217728
net.core.wmem_max = 134217728

# TCP buffer auto-tuning
net.ipv4.tcp_rmem = 4096 87380 67108864
net.ipv4.tcp_wmem = 4096 65536 67108864

# Increase network device backlog queue
net.core.netdev_max_backlog = 5000

# Increase softirq processing budget
net.core.netdev_budget = 600

# Enable TCP window scaling
net.ipv4.tcp_window_scaling = 1
```

Apply immediately:

```bash
sysctl -p /etc/sysctl.d/99-network-tuning.conf
```

**What these do:**
- `rmem_max/wmem_max`: Maximum socket buffer sizes (increased from ~200KB to 128MB)
- `tcp_rmem/tcp_wmem`: TCP buffer auto-tuning ranges
- `netdev_max_backlog`: How many packets can queue before dropping
- `netdev_budget`: How many packets to process per softirq cycle

---

## Step 4: Make It Persistent

The `ethtool` and RPS changes reset on reboot. Let's fix that.

Create `/etc/systemd/system/network-tuning.service`:

```ini
[Unit]
Description=Network Performance Tuning
After=network-online.target
Wants=network-online.target

[Service]
Type=oneshot
RemainAfterExit=yes
# Replace eth0 with your interface name and fff with your CPU mask
ExecStart=/bin/bash -c 'echo "fff" > /sys/class/net/eth0/queues/rx-0/rps_cpus'
ExecStart=/usr/sbin/ethtool -G eth0 rx 4096 tx 4096

[Install]
WantedBy=multi-user.target
```

> ⚠️ **Important**: Replace `eth0` with your interface name and `fff` with your CPU mask!

Enable it:

```bash
systemctl daemon-reload
systemctl enable network-tuning.service
systemctl start network-tuning.service
```

---

## Step 5: Verify the Fix

Now let's confirm everything is working:

### Monitor interrupt distribution:
```bash
watch -n 2 'cat /proc/interrupts | grep -E "CPU|eth0"'
```

You should see interrupts spreading across all cores.

### Check for packet drops:
```bash
netstat -s | grep -iE 'drop|prune|collapse'
```

Before the fix, I was seeing thousands of dropped packets. After: zero.

### Watch softirq distribution:
```bash
watch -n 2 'cat /proc/softirqs | grep -E "CPU|NET_RX"'
```

NET_RX should be relatively balanced across cores (not perfectly even, but no single core with 10x load).

### Real-world test:
```bash
# From another machine
ping your-server-ip -c 100
```

Before: 5-10% of pings had 200-500ms spikes  
After: Consistent sub-5ms responses

---

## Mistakes I Made

1. **Didn't check security first** (initially): I jumped straight into performance tuning before ruling out crypto miners. Always check security first.

2. **Used wrong RPS mask**: I initially used `f` (4 CPUs) when I had 12 cores. Check with `nproc`!

3. **Forgot to persist settings**: Spent 2 hours tuning, rebooted for an update, everything reset. Always create the systemd service.

4. **Didn't monitor before/after**: I wish I had captured baseline metrics before starting. Always document your "before" state.

---

## What I Learned

### Why irqbalance wasn't running

Debian/Ubuntu don't always install `irqbalance` by default. It should be standard on any server handling real traffic.

### The "observer effect" isn't paranormal

When tools run on different cores, they trigger kernel activity that shifts workload. It's not magic - it's just the scheduler doing its job differently under load.

### Network tuning is a stack

There's no single "fix network lag" command. It's:
- Hardware interrupt distribution (irqbalance)
- Software packet steering (RPS)
- Buffer sizing (ring buffers)
- Kernel parameters (sysctl)
- All working together

### Modern NICs need modern settings

Default settings from 2010 don't work well with 2025 network speeds. A 256-packet ring buffer is absurdly small for a gigabit NIC.

---

## When Does This Matter?

> 💭 **Reality check**: If your homelab serves 3 users and a Plex stream, you probably don't need this. But if you're running:
> - Multiple containers with web services
> - Game servers
> - VPN gateways handling real traffic
> - Network-intensive applications
> 
> Then yes, IRQ balance matters. My server went from "randomly frustrating" to "rock solid" after this fix.

---

## Rollback (If Needed)

If something breaks:

```bash
# Stop and disable our tuning service
systemctl stop network-tuning.service
systemctl disable network-tuning.service

# Reset ring buffers to defaults
ethtool -G eth0 rx 256 tx 256

# Remove sysctl tuning
rm /etc/sysctl.d/99-network-tuning.conf
sysctl -p

# Stop irqbalance
systemctl stop irqbalance
systemctl disable irqbalance

# Reboot to fully reset
reboot
```

---

## Resources

- [Linux Kernel Documentation: Scaling](https://www.kernel.org/doc/Documentation/networking/scaling.txt)
- [Red Hat: Performance Tuning Guide](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/7/html/performance_tuning_guide/)
- [irqbalance on GitHub](https://github.com/Irqbalance/irqbalance)

---

Got questions? Found this helpful? Let me know - I'd love to hear your debugging stories too.

*Update 2025-12-11: Initial publication*
