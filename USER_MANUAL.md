<div align="center">

# Sentri — User Manual

**AI-powered Neural Firewall for Android · Version 1.0.0**

</div>

This manual explains how to set up and operate the Sentri app as an end user. For installation from
source and developer setup, see the [README](README.md). For the full technical design, see
[MOBILE_REPORT.md](MOBILE_REPORT.md).

---

## Table of Contents

1. [What Sentri Does](#1-what-sentri-does)
2. [Before You Begin](#2-before-you-begin)
3. [First-Time Setup](#3-first-time-setup)
4. [Turning Protection On & Off](#4-turning-protection-on--off)
5. [The Screens](#5-the-screens)
   - [Home — Live Traffic](#51-home--live-traffic)
   - [Dashboard — Overview](#52-dashboard--overview)
   - [Analytics](#53-analytics)
   - [Firewall Logs — History](#54-firewall-logs--history)
   - [Blacklist](#55-blacklist)
   - [Settings](#56-settings)
   - [Nova — AI Assistant](#57-nova--ai-assistant)
6. [Understanding Verdicts](#6-understanding-verdicts)
7. [Managing Blocked Addresses](#7-managing-blocked-addresses)
8. [Tuning Detection](#8-tuning-detection)
9. [Privacy & Data](#9-privacy--data)
10. [FAQ](#10-faq)
11. [Glossary](#11-glossary)

---

## 1. What Sentri Does

Sentri turns your Android phone into a self-contained firewall. When protection is on, **every**
network packet your device sends or receives is routed through Sentri, inspected, and scored by
on-device AI. Traffic judged malicious is blocked at the network level and its source is added to a
block list — all in real time, and all on your device (your traffic is never sent elsewhere to be
analysed).

Sentri keeps you online the whole time: clean traffic is forwarded to the internet instantly, so
inspection never slows you down.

---

## 2. Before You Begin

You need:

- An **Android phone** running Android 8.0 (API 26) or newer.
- An internet connection for sign-up, login, and syncing history (the firewall itself keeps working offline).
- Willingness to grant the **VPN permission** — this is how Sentri captures and protects your traffic. Sentri uses the VPN mechanism _locally_ to inspect packets; it is not a remote VPN and does not route your data through a third party.

> **Only one active VPN at a time.** Android allows a single VPN tunnel. If another VPN app is running, turn it off before enabling Sentri.

---

## 3. First-Time Setup

1. **Launch the app.** You'll land on the sign-in screen.
2. **Create an account** — tap _Sign Up_, enter your details, and register. (Or _Sign In_ if you already have an account.)
3. Once signed in, you'll see the main app with a floating navigation bar at the bottom.
4. **Enable protection** (see next section). The first time, Android shows a **connection request** dialog asking you to allow Sentri to set up a VPN connection — tap **OK / Allow**.
5. Sentri starts capturing traffic. Within seconds you'll see packets flowing on the **Home** screen.

Your login is stored securely (encrypted) on the device, so you stay signed in across restarts. If
you're briefly offline at startup, Sentri restores your last session from its secure cache rather
than logging you out.

---

## 4. Turning Protection On & Off

- Protection is controlled by the **VPN toggle** on the Home screen.
- **On** → Sentri builds its tunnel, starts inspecting traffic, and shows a persistent notification (Android requires this for an always-on service).
- **Off** → the tunnel is torn down and inspection stops. Your traffic flows normally, unprotected.

**Always-on behaviour:** once enabled, Sentri runs as a _sticky_ foreground service. If Android
restarts it (e.g. under memory pressure) or you reboot and reopen the app, protection resumes
automatically — and known blocked addresses stay blocked from the moment capture restarts, even
before the app's UI has fully reconnected.

---

## 5. The Screens

Sentri has four main tabs in the floating navigation bar — **Home**, **Dashboard/Portal**,
**Blacklist**, and **Settings** — plus a floating **Nova** button for the AI assistant. Firewall
Logs and Analytics are reached from the Dashboard.

### 5.1 Home — Live Traffic

The operational heart of the app.

- **Protection toggle** — turn the firewall on/off.
- **Live traffic table** — a real-time stream of the most recent flows (capped at the latest 200). Each row shows the source/destination, protocol, size, the owning app or resolved service name (e.g. "YouTube" instead of a raw IP), the chosen model and its score, and the verdict.
- **Threat sparkline** — a rolling 60-point mini-chart of threat intensity over time.
- **Session stats** — packets analysed, and safe / warned / blocked counts.

### 5.2 Dashboard — Overview

A calm, at-a-glance summary of your protection posture:

- **Protection hero** — overall status.
- **Session statistics** — packets analysed, blocked, warned, safe, and peak threat percentage.
- **Hardware stats** — CPU usage, RAM, and battery, with threshold-coloured gauges, so you can see Sentri's footprint.
- **Recent blocked IPs** and **active-model chips** showing which detectors are enabled.

### 5.3 Analytics

Deeper views built from your live session:

- **Verdict breakdown** — proportion of safe / warn / blocked.
- **Threat-vector intensities** — average and peak brute-force and DoS scores.
- **Top source IPs** — the addresses generating the most traffic.
- **Protocol mix** — the balance of TCP / UDP / other.

### 5.4 Firewall Logs — History

A searchable, paginated history of firewall verdicts, backed by the server so it persists and syncs
across devices.

- **Infinite scroll** and **pull-to-refresh**.
- **Filters** — by action (safe/warn/block), threat type, service name, application name, and date range.
- Each entry records source IP/port, destination port, protocol, size, the selected model and score, the full per-model score map, the final action, threat type, resolved service/app names, and whether the traffic was from a system app.

### 5.5 Blacklist

Your list of blocked IP addresses.

- **Local-first** — entries take effect immediately at the network level and are stored on-device, so they work even offline, then sync to the server best-effort.
- Addresses appear here either because **you added them manually** or because **Sentri auto-blocked** them after a malicious verdict (these appear in real time).
- The navigation bar shows a **live badge** with the current blocked count.
- **Removing** an entry lifts the network block and restores connectivity to that address.

### 5.6 Settings

Live control over how the firewall behaves. Changes apply immediately — no restart needed.

- **Block threshold** / **Warn threshold** — the scores at which a flow is blocked or flagged.
- **Per-model AI toggles** — enable/disable individual detectors (Brute Force, DoS, HULK, LOIC, HOIC).
- **Flood & SYN-flood detection** limits.
- **System-traffic scanning** — whether to inspect OS/system-owned traffic.
- **Maximum log entries** kept.
- **Theme** — light or dark.

Settings are saved locally right away and synced to the server shortly after; server-side changes
(e.g. from an administrator) are applied to your live pipeline automatically.

### 5.7 Nova — AI Assistant

Tap the floating **Nova** button to open a conversational security assistant. Ask natural-language
questions about _your own_ traffic, such as:

- "Who is attacking me?"
- "Top threats today"
- "Is my device safe?"

The empty chat offers **suggestion chips** with these prompts — tap one to start instantly. Nova
streams its answer word-by-word (you'll see a "thinking" indicator and a live cursor).

Nova is **stateless by design**: there's no saved history. Each question is answered on its own, and
starting a _new chat_ simply clears the screen.

---

## 6. Understanding Verdicts

Every inspected flow is classified into one of these outcomes:

| Verdict         | Meaning                                                       | What happens                                                                   |
| --------------- | ------------------------------------------------------------- | ------------------------------------------------------------------------------ |
| 🟢 **Safe**     | All detectors scored below the warn threshold.                | Traffic flows normally.                                                        |
| 🟡 **Warn**     | Top score is between the warn and block thresholds.           | Flagged for your attention; traffic still flows.                               |
| 🔴 **AI Block** | Top score meets or exceeds the block threshold.               | Packet dropped, source auto-blocked, any in-flight connection to it torn down. |
| 🔵 **Special**  | Recognised protocol events (TCP handshakes, QUIC, ICMP ping). | Labelled directly, not scored as a threat.                                     |

Two fast paths run _before_ the AI for efficiency: traffic to an **already-blocked** address is
blocked instantly, and benign **system traffic** to well-known ports (DNS, web, push, etc.) is
skipped to save battery — unless it starts behaving like a flood, in which case it's fully scored.

---

## 7. Managing Blocked Addresses

- **Block manually:** add an IP on the Blacklist screen. It takes effect immediately.
- **Automatic blocks:** appear on the Blacklist in real time whenever the AI issues a block verdict.
- **Unblock:** remove the entry — the network block is lifted and connectivity to that address is restored.
- Blocks are **saved to disk** and reloaded every time protection starts, so threats stay blocked across reboots and app restarts.
- Your own device address is protected and can never be blocked (which would otherwise cut off all traffic).

---

## 8. Tuning Detection

If Sentri is too aggressive or not aggressive enough, adjust it in **Settings**:

- **Too many false blocks?** Raise the **block threshold** (e.g. from 0.80 toward 0.90), or disable a specific model that's over-firing.
- **Want earlier warnings?** Lower the **warn threshold**.
- **Battery-conscious?** Keep **system-traffic scanning** off so routine OS traffic is skipped.
- **Targeting a specific attack type?** Enable only the relevant model(s) — e.g. Brute Force Guard for login-attack scenarios.

All changes take effect on the live pipeline instantly.

---

## 9. Privacy & Data

- **Detection is 100% on-device.** Your packets are inspected and classified locally by the bundled AI models — traffic contents are never uploaded for analysis.
- **What syncs to the backend:** firewall verdicts (metadata such as IPs, ports, verdict, model score), your blacklist, your settings, and periodic hardware snapshots — used for history, cross-device sync, and the Nova assistant.
- **Credentials** (login tokens) are stored in encrypted, platform-backed secure storage (Android EncryptedSharedPreferences).
- **All backend communication is over HTTPS.**
- **Offline:** the firewall, its history, block list, and settings all keep working with no connection; the server is a best-effort mirror that catches up when you're back online.

---

## 10. FAQ

**Does Sentri route my traffic through a remote server?**
No. It uses Android's VPN mechanism _locally_ to see your packets. Traffic goes straight to the real internet; only verdict metadata is later synced.

**Will it slow down my internet?**
No. Clean packets are forwarded to the internet before the AI runs, so inspection happens in parallel and doesn't add latency.

**Why does it need a persistent notification?**
Android requires any always-on background service to show one. It's how Sentri stays alive to keep protecting you.

**Does it work on an iPhone / emulator?**
No. Sentri's engine is Android-specific and requires a **physical** Android device.

**I use another VPN — can I run both?**
Not at the same time. Android allows only one active VPN tunnel.

**What happens after a reboot?**
Reopen Sentri; protection resumes automatically and previously blocked addresses stay blocked.

**Can I lose my blacklist if I go offline?**
No. It's stored on-device first and works fully offline; it syncs to the server when a connection returns.

---

## 11. Glossary

| Term                 | Meaning                                                                                                                |
| -------------------- | ---------------------------------------------------------------------------------------------------------------------- |
| **Flow**             | A single network conversation between your device and a remote address (identified by source/destination IP and port). |
| **Verdict**          | The firewall's decision for a flow: safe, warn, block, or special.                                                     |
| **Threshold**        | The score cut-off that decides warn vs. block.                                                                         |
| **Model / Detector** | One of the five specialised AI classifiers (Brute Force, DoS, HULK, LOIC, HOIC).                                       |
| **Blacklist**        | Your list of blocked IP addresses.                                                                                     |
| **TUN interface**    | The virtual network device Sentri uses to capture all traffic.                                                         |
| **Auto-block**       | An automatic block triggered by an AI verdict.                                                                         |
| **Nova**             | The built-in conversational AI assistant.                                                                              |
| **System traffic**   | Network activity owned by the operating system rather than a user app.                                                 |

---

<div align="center">
<sub>Sentri Neural Firewall · User Manual · v1.0.0</sub>
</div>
