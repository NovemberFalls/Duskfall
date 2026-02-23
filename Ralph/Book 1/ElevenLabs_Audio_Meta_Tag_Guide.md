# ElevenLabs Audio Meta-Tagging Guide (Eleven v3)

**Version:** v3 Alpha
**Purpose:** Precision emotional, tonal, and performance control for AI narration

---

## Overview

ElevenLabs **Audio Tags** (also referred to as *meta tags*) allow you to control *how* text is spoken  not just *what* is spoken.

These tags are placed in **square brackets** within your script and are interpreted by the **Eleven v3 model** to influence:

* Emotion
* Delivery style
* Volume
* Character direction
* Sound effects
* Human reactions
* Pacing and pauses

>  Audio tags are only supported by **Eleven v3 (Alpha)**.

---

## Core Syntax Rules

### 1. Basic Format

```
[tag] Text to be spoken.
```

### 2. Multiple Tags

```
[whispers][nervous] I dont think were alone.
```

### 3. Placement

Tags should be placed immediately before the text they influence.

```
[sorrowful] I never thought wed see the sun again.
```

### 4. Case Sensitivity

Tags are **not case sensitive**:

```
[Excited]
[excited]
[EXCITED]
```

All function the same.

---

## Tag Categories

---

## 1. Emotion & Tone

Use to shape emotional delivery.

Examples:

```
[excited]
[sad]
[nervous]
[frustrated]
[sorrowful]
[angry]
[hopeful]
```

Example:

```
[sorrowful] The gates have fallen.
```

---

## 2. Delivery Style & Volume

Control how loudly or softly something is delivered.

Examples:

```
[whispers]
[shouts]
[quietly]
[loudly]
[dramatic tone]
```

Example:

```
[whispers] Stay quiet.
```

---

## 3. Human Reactions

Adds natural vocal behaviors.

Examples:

```
[laughs]
[sighs]
[clears throat]
[gulps]
[chuckles]
```

Example:

```
[sighs] I suppose we have no choice.
```

---

## 4. Sound Effects

Inject non-verbal sound cues.

Examples:

```
[gunshot]
[explosion]
[applause]
[door creaks]
[thunder]
```

Example:

```
[explosion] The walls shattered into dust.
```

---

## 5. Accent & Character Direction

Guide stylistic changes without switching voices.

Examples:

```
[British accent]
[pirate voice]
[gravelly voice]
[royal tone]
```

Example:

```
[pirate voice] Arr, we sail at dawn.
```

---

## 6. Pacing & Narrative Control

Refine timing and dramatic rhythm.

Examples:

```
[slow]
[fast]
[pause]
[short pause]
[long pause]
```

Example:

```
[slow] The last torch went out.
[short pause]
[sorrowful] Then the screams began.
```
