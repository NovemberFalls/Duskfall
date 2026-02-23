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
[pause]
[hesitates]
[drawn out]
[slows down]
[speaks faster]
```

Example:

```
[pause] Then the screaming began.
```

---

## Advanced Usage

### Layering Tags

Combine multiple tags for nuanced control:

```
[whispers][nervous] Did you hear that?
```

### Mid-Sentence Tags

Tags can be inserted mid-line:

```
I never thought  [hesitates]  it would end like this.
```

---

## Narrative Example

```
[sorrowful] The city of Emberfall lies in ruin. 
[pause] 
[whispers] And we were too late.
```

---

## Multi-Character Dialogue Example

```
[whispers] November: Did you hear that?
[loudly] Horus: I heard it  and Im not afraid!
[sighs] November: You should be.
```

---

## Best Practices

* Use tags sparingly for maximum impact.
* Place tags immediately before affected text.
* Layer tags carefully.
* Test with expressive voices for best results.
* Avoid over-cluttering your script with excessive direction.
* Eleven v3 does **not** support SSML `<break>` tags. Use audio tags and punctuation for pauses.
* Punctuation is a strong control lever (ellipses, em dashes, capitalization) for rhythm.
* Tag effectiveness depends on voice; match tags to the voice’s character.
* Longer prompts (>250 characters) are more stable for v3.
* Narrative-style writing improves pacing; avoid overly fragmented lines.
* Explicit emotional context or dialogue tags can improve emotion delivery consistency.
* If pacing feels fast/slow, adjust voice speed settings (0.7–1.2 range) and retest.
* Use dashes or ellipses for short pauses when needed (v3 ignores SSML breaks).
* For emotion, direct dialogue tags tend to be more predictable than context alone.
* Pacing depends on the voice itself; longer, continuous training samples help reduce overly fast delivery.
* If pronunciation is off, try phonetic spellings, capitalization, or alias tags in a pronunciation dictionary (phoneme tags are not supported by v3).

---

## Limitations

* Only supported in **Eleven v3 Alpha**.
* Performance varies depending on voice model.
* Some integrations may not fully support audio tags yet.
* SSML break tags are not supported in v3; use `[pause]`/`[short pause]`/`[long pause]` instead.
* Phoneme tags are not supported by v3; they only work on specific non-v3 models.

---

## Quick Reference Cheat Sheet

| Category  | Example Tags                         |
| --------- | ------------------------------------ |
| Emotion   | `[sad]`, `[angry]`, `[hopeful]`      |
| Volume    | `[whispers]`, `[shouts]`             |
| Reactions | `[laughs]`, `[sighs]`                |
| Effects   | `[explosion]`, `[gunshot]`           |
| Accent    | `[British accent]`, `[pirate voice]` |
| Pacing    | `[pause]`, `[hesitates]`             |

---

## Recommended File Name

```
ElevenLabs_Audio_Meta_Tag_Guide_v3.md
```
