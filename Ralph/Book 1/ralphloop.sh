#!/bin/bash
set -euo pipefail

ITERATIONS="$1"
MODEL="gpt-5.2-codex"
OUTPUT_SUFFIX="${OUTPUT_SUFFIX:-}"
BASE_SUFFIX="${BASE_SUFFIX:-_v2}"
AUDIO_MODE="${AUDIO_MODE:-0}"
AUDIO_BOOK_MODE="${AUDIO_BOOK_MODE:-0}"
AUDIO_BOOK_SUFFIX="${AUDIO_BOOK_SUFFIX:-_audio_book}"
SKIP_GIT="${SKIP_GIT:-0}"

PRD_FILE="prd.md"
PROGRESS_FILE="progress.txt"

WORLD_FILES=(
    "World/00 - Premise.md"
    "World/01 - POV Characters.md"
    "World/02 - Themes and Emotional Beats.md"
    "World/03 - November Falls - Character Bible.md"
    "World/04 - Writing Rules.md"
    "World/05 - November Falls - Personality Profile.md"
    "../../Lore/Wars/The Veilfire War/Bloodhollow/Crimsonmarch/0099-09-01 - Emberfall - The Blackroot Siege.md"
)

for ((i=1; i<=ITERATIONS; i++)); do

    TASK=$(grep -m1 "\[ \] C" "$PRD_FILE" || true)

    if [ -z "$TASK" ]; then
        echo "All tasks complete."
        exit 0
    fi

    CHAPTER=$(echo "$TASK" | grep -o "C[0-9][0-9]")

    CHAPTER_DIR="Chapters/$CHAPTER"
    DECISION_DIR="Chapters/Decisions"
    mkdir -p "$CHAPTER_DIR"
    mkdir -p "$DECISION_DIR"

    CLARIFY_FILE="$DECISION_DIR/$CHAPTER - Clarify.md"
    DECISION_FILE="$DECISION_DIR/$CHAPTER - Decision.md"

    TITLE=""
    if [ -f "$CLARIFY_FILE" ]; then
        TITLE=$(grep -m1 '^Title:' "$CLARIFY_FILE" | sed 's/^Title:[[:space:]]*//')
        TITLE=$(printf "%s" "$TITLE" | tr '/\\:' '-' | tr -d '\r' | tr -d '<>"|?*')
    fi
    if [ -n "$TITLE" ]; then
        OUTPUT_FILE="$CHAPTER_DIR/$CHAPTER - $TITLE${OUTPUT_SUFFIX}.md"
    else
        OUTPUT_FILE="$CHAPTER_DIR/$CHAPTER - Draft${OUTPUT_SUFFIX}.md"
    fi

    CONTEXT=""
    for FILE in "${WORLD_FILES[@]}"; do
        CONTEXT+="$(cat "$FILE")"$'\n\n'
    done

    CLARIFY_TEXT=""
    if [ -f "$CLARIFY_FILE" ]; then
        CLARIFY_TEXT=$'\n\nCLARIFICATIONS:\n'"$(cat "$CLARIFY_FILE")"
    fi

    DECISION_TEXT=""
    if [ -f "$DECISION_FILE" ]; then
        DECISION_TEXT=$'\n\nDECISION RESOLUTION (follow this):\n'"$(cat "$DECISION_FILE")"
    fi

    AUDIO_TAG_GUIDE=""
    if [ -f "ElevenLabs_Audio_Meta_Tag_Guide_v3.md" ]; then
        AUDIO_TAG_GUIDE=$'\n\nAUDIO TAG GUIDE (follow in AUDIO_MODE):\n'"$(cat "ElevenLabs_Audio_Meta_Tag_Guide_v3.md")"
    fi
    AUDIO_BOOK_GUIDE=""
    if [ -f "World/07 - Eleven Labs Audio Book" ]; then
        AUDIO_BOOK_GUIDE=$'\n\nAUDIO BOOK GUIDE (follow in AUDIO_BOOK_MODE):\n'"$(cat "World/07 - Eleven Labs Audio Book")"
    fi

    BASE_TEXT=""
    if [ "$AUDIO_BOOK_MODE" = "1" ]; then
        AUDIO_MODE="1"
    fi
    if [ "$AUDIO_MODE" = "1" ]; then
        if [ -n "$TITLE" ]; then
            BASE_FILE="$CHAPTER_DIR/$CHAPTER - $TITLE${BASE_SUFFIX}.md"
        else
            BASE_FILE="$CHAPTER_DIR/$CHAPTER - Draft${BASE_SUFFIX}.md"
        fi
        if [ -f "$BASE_FILE" ]; then
            BASE_TEXT=$'\n\nBASE_TEXT (rewrite for audio pacing, keep content and POV):\n'"$(cat "$BASE_FILE")"
        else
            echo "Audio mode requested but base file not found: $BASE_FILE"
            exit 1
        fi
        if [ -z "$OUTPUT_SUFFIX" ]; then
            if [ "$AUDIO_BOOK_MODE" = "1" ]; then
                OUTPUT_SUFFIX="$AUDIO_BOOK_SUFFIX"
            else
                OUTPUT_SUFFIX="_audio"
            fi
            if [ -n "$TITLE" ]; then
                OUTPUT_FILE="$CHAPTER_DIR/$CHAPTER - $TITLE${OUTPUT_SUFFIX}.md"
            else
                OUTPUT_FILE="$CHAPTER_DIR/$CHAPTER - Draft${OUTPUT_SUFFIX}.md"
            fi
        fi
    fi

    PROMPT="$CONTEXT

TASK: $TASK
$CLARIFY_TEXT
$DECISION_TEXT
$BASE_TEXT
$AUDIO_TAG_GUIDE
$AUDIO_BOOK_GUIDE

Write full draft (3,000-5,000 words).

Follow Writing Rules strictly.
Do not revise previous chapters.
Do not write files or run tools. Output only the draft text.
If AUDIO_MODE is on, rewrite BASE_TEXT for audiobook pacing and clarity. Do not add new plot. Keep POV and tense.
If AUDIO_MODE is on, embed ElevenLabs meta tags from the guide. REQUIRE: every spoken line of dialogue must have a tag immediately before it (same line, directly preceding the quote). If any dialogue line lacks a tag, rewrite until all dialogue lines are tagged. Add tags to narration only when sentiment/intent is clear and it improves delivery. Do not tag every paragraph.
If AUDIO_MODE is on, keep paragraph flow novel-like. Avoid breaking into many single-line sentences. Only use single-line sentences when they are intentionally powerful. Combine short beats into fuller paragraphs while preserving rhythm.
If AUDIO_MODE is on, use punctuation (ellipses, em dashes, commas) to control micro-pauses instead of SSML breaks (not supported in v3).
Avoid repetition. Vary sentence structure and imagery; no echoing phrases within a scene.
If AUDIO_BOOK_MODE is on, optimize for ElevenLabs Studio audiobook ingestion: consistent paragraph breaks, no headings unless present in BASE_TEXT, no extra metadata, and use tags sparingly but on every dialogue line.

LANGUAGE & VOICE BY RACE:
- Orcs: rough, clipped, low-grammar. Short clauses, hard consonants. No polished English.
- Goblins: quick, fractured, sly. Choppy rhythm, slangy, implied cunning. No polished English.
- Trolls/others: simple, blunt, reduced syntax. Keep them distinct from orcs/goblins.
- Humans/Elves/etc: normal prose, but in-scene dialogue should match their background.
If unsure about a race's voice, stop and ask for clarification.

STONEVEIL MORALITY (from Humans.md):
- Alignment: Lawful Neutral. Duty over personal gain.
- Stoic, uncompromising, deeply pragmatic.
- Not heartless: he feels cost but suppresses it; morality expressed as restraint and burden, not speeches.

TONE UPGRADE:
- Grimdark, dreadful, almost horrific, but with a thin line of light in the darkness.
- Bitter-sweet: small human warmth amid ruin, never undercutting stakes.
- Prose should be sharp and tactile; no purple flourishes, no generic fantasy phrasing.
PACING PRIORITY:
- Scene economy matters. Build a clear arc with escalation; avoid a day-in-the-life collage.
- Limit civilian-helping vignettes to at most one short beat unless plot-critical.
- Include one or two specific intimacy/domestic moments only if they intensify later loss.
- Preserve a strong tragic engine: if the protagonist leaves a safe place before the strike, it should seed guilt later.
- Signal siege stakes early (the wall, the orcs, rumors) without heavy exposition.
If moral crossroads appears, output:

DECISION REQUIRED:
Chapter:
Context:
Options:
"

    PROMPT_FILE="$(mktemp)"
    printf "%s" "$PROMPT" > "$PROMPT_FILE"
    RESPONSE=$(codex exec -m "$MODEL" < "$PROMPT_FILE")
    rm -f "$PROMPT_FILE"

    if echo "$RESPONSE" | grep -q "DECISION REQUIRED"; then
        DECISION_FILE="$DECISION_DIR/$CHAPTER - Decision.md"
        echo "$RESPONSE" > "$DECISION_FILE"
        echo "Decision required. Halting."
        exit 0
    fi
    if echo "$RESPONSE" | grep -qiE "before i draft|need a couple specifics|which pov|must-hit beats"; then
        CLARIFY_FILE="$DECISION_DIR/$CHAPTER - Clarify.md"
        echo "$RESPONSE" > "$CLARIFY_FILE"
        echo "Clarification required. Halting."
        exit 0
    fi

    echo "$RESPONSE" > "$OUTPUT_FILE"

    sed -i '0,/\[ \] C/ s/\[ \] C/\[x\] C/' "$PRD_FILE"

    echo "[$(date '+%Y-%m-%d %H:%M')] $MODEL | $CHAPTER | Draft Complete" >> "$PROGRESS_FILE"

    if [ "$AUDIO_MODE" = "1" ]; then
        SKIP_GIT="1"
    fi
    if [ "$SKIP_GIT" != "1" ]; then
        git add .
        git commit -m "Layer 1 Draft $CHAPTER"
    fi

done
